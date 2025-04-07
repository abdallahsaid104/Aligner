`ifndef ALIGNER_MODEL_SV
    `define ALIGNER_MODEL_SV
    `uvm_analysis_imp_delc(_in_rx)
    `uvm_analysis_imp_delc(_in_tx)

    class Aligner_model extends uvm_component implements uvm_ext_reset_handler;

        Aligner_env_config env_config;

        Aligner_reg_block reg_block;
        
        uvm_analysis_imp_in_rx#(md_item_mon, Aligner_model) port_in_rx;

        uvm_analysis_imp_in_tx#(md_item_mon, Aligner_model) port_in_tx;

        uvm_analysis_port#(md_response) port_out_rx;

        uvm_analysis_port#(md_item_mon) port_out_tx;

        uvm_analysis_port#(bit) port_out_irq;

        uvm_analysis_port#(split_info) port_out_split_info;

        protected uvm_tlm_fifo#(md_item_mon) rx_fifo;

        protected uvm_tlm_fifo#(md_item_mon) tx_fifo;

        protected md_item_mon buffer[$];

        protected bit exp_irq;

        protected uvm_event tx_complete;

        local process process_push_to_rx_fifo;local process process_push_to_rx_fifo;

        local process process_build_buffer;

        local process process_align;

        local process process_tx_ctlr;

        protected process process_set_rx_fifo_empty;

        protected process process_set_rx_fifo_full;

        protected process process_set_tx_fifo_empty;
        
        protected process process_set_tx_fifo_full;

        protected process process_send_exp_irq;

        `uvm_copmonent_utils(Aligner_model)

        function new(string name = "Aligner_model", uvm_component parent = null);
            super.new(name, parent);
            port_in_tx   = new("port_in_tx", this);
            port_out_rx  = new("port_out_rx", this);
            port_out_tx  = new("port_out_tx", this);
            port_out_irq = new("port_out_irq", this); 
            port_out_split_info = new("port_out_split_info", this);

            rx_fifo = new("rx_fifo", this, 8);
            tx_fifo = new("tx_fifo", this, 8);

            tx_complete = new("tx_complete");
        endfunction

        /*-----------------------------------------------------------------------------------------*/
        /*-------------------------------------- Phases -------------------------------------------*/
        /*-----------------------------------------------------------------------------------------*/

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if(reg_block == null) begin
                reg_block = Aligner_reg_block::type_id::create("reg_block");

                reg_block.build();
                reg_block.lock_model();
            end
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            Aligner_clr_cnt_drop cbs = Aligner_clr_cnt_drop::type_id::create("cbs");

            super.connect_phase(phase);

            // Connect the pointer to cnt_drop
            cbd.cnt_drop = reg_block.STATUS.CNT_DROP;

            // Register the callback
            uvm_callbacks#(uvm_reg_field, Aligner_clr_cnt_drop)::add(reg_block.CTRL.CLR, cbs);

        endfunction

        virtual function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);
            
            reg_block.CTRL.SET_ALGN_DATA_WIDTH(env_config.get_algn_data_width());
        endfunction

        /*-----------------------------------------------------------------------------------------*/
        /*-------------------------- Functions associated with RX/TX ports ------------------------*/
        /*-----------------------------------------------------------------------------------------*/
        virtual function void write_in_rx(md_item_mon item);
            if(item.is_active()) begin
                md_response exp_response = get_exp_response(item);

                case(exp_response)
                MD_ERROR: begin
                    inc_cnt_drop(exp_response);

                    port_out_rx.write(exp_response);
                end
                MD_OK: begin
                    push_to_rx_fifo_nb(md_item_mon item)
                end
                defualt: begin
                    `uvm_fatal("ISSUE", $sformatf("Un-supported value for response:%0s", exp_response.name()))
                end
                endcase
            end
        endfunction

        virtual function void write_in_tx(md_item_mon item);
            if(!item.is_active()) begin
                tx_complete.trigger();
            end

        endfunction

        protected virtual function md_response get_exp_response(md_item_mon item);
            // Size of access is 0
            if(item.data.size() == 0 ) begin
                return MD_ERROR;
            end

            // Illegal combinantion between offset and size
            if((env_config.get_algn_data_width()/8 + item.offset) % item.data.size() !== 0) begin
                return MD_ERROR;
            end

            if((item.offset+item.data.size()) > (env_config.get_algn_data_width() / 8)) begin
                return MD_ERROR;
            end
            return MD_OK;
        endfunction

        /* ----------------- Inc/dec flags functions ---------------------------*/
        protected  virtual function void inc_cnt_drop(md_response response);
            // max_value = 'h11111111
            uvm_reg_data_t max_value = ('h1 << reg_block.STATUS.CNT_DROP.get_n_bits()) - 1;
        
            if(reg_block.STATUS.CNT_DROP.get_mirrored_value() < max_value) begin
                void'(reg_block.STATUS.CNT_DROP.predict(reg_block.STATUS.CNT_DROP.get_mirrored_value() + 1));
                
                `uvm_info("DEBUG", $sformatf("Increment %0s: %0d due to: %0s",
                                            reg_block.STATUS.CNT_DROP.get_full_name(),
                                            reg_block.STATUS.CNT_DROP.get_mirrored_value(),
                                            response.name()), UVM_NONE)
                
                if(reg_block.STATUS.CNT_DROP.get_mirrored_value() == max_value) begin
                    set_max_drop();
                end
            end

        endfunction

        protected virtual function void inc_rx_lvl();
            void'(reg_block.STATUS.RX_LVL.predict(reg_block.STATUS.RX_LVL.get_mirrored_value() + 1 ));

            if(reg_block.STATUS.RX_LVL.get_mirrored_value() == rx_fifo.size()) begin
                set_rx_fifo_full();
            end
        endfunction

        protected virtual function void dec_rx_lvl();
            void'(reg_block.STATUS.RX_LVL.predict(reg_block.STATUS.RX_LVL.get_mirrored_value() - 1 ));

            if(reg_block.STATUS.RX_LVL.get_mirrored_value() == 0) begin
                set_rx_fifo_empty();
            end
        endfunction

        protected virtual function void inc_tx_lvl();
            void'(reg_block.STATUS.TX_LVL.predict(reg_block.STATUS.TX_LVL.get_mirrored_value() + 1 ));

            if(reg_block.STATUS.TX_LVL.get_mirrored_value() == tx_fifo.size()) begin
                set_tx_fifo_full();
            end
        endfunction

        protected virtual function void dec_tx_lvl();
            void'(reg_block.STATUS.TX_LVL.predict(reg_block.STATUS.TX_LVL.get_mirrored_value() - 1 ));

            if(reg_block.STATUS.TX_LVL.get_mirrored_value() == 0) begin
                set_tx_fifo_empty();
            end
        endfunction

        /* ----------------------- push/pop functions ------------------------------*/
        protected virtual task push_to_rx_fifo(md_item_mon item);
            sync_push_to_rx_fifo();
            rx_fifo.put(item);

            kill_set_rx_fifo_empty();

            inc_rx_lvl();

            `uvm_info("DEBUG",$sformatf("RX-FIFO push - new level:%0d pused_entry:%0d",
                                        reg_block.STATUS.RX_LVL.get_mirrored_value(),
                                        item.cov2str()),UVM_NONE)
            port_out_rx.write(MD_OK);
        endtask

        protected virtual task pop_from_rx_fifo(md_item_mon item);
            sync_pop_from_rx_fifo();
            rx_fifo.get(item);

            kill_set_rx_fifo_full();

            dec_rx_lvl();

            `uvm_info("DEBUG",$sformatf("RX-FIFO pop - new level:%0d pused_entry:%0d",
                                        reg_block.STATUS.RX_LVL.get_mirrored_value(),
                                        item.cov2str()),UVM_NONE)
            
        endtask

        protected virtual task pop_from_tx_fifo(md_item_mon item);
            sync_pop_from_tx_fifo();
            tx_fifo.get(item);

            kill_set_tx_fifo_full();

            dec_tx_lvl();

            `uvm_info("DEBUG",$sformatf("TX-FIFO pop - new level:%0d pused_entry:%0d",
                                        reg_block.STATUS.TX_LVL.get_mirrored_value(),
                                        item.cov2str()),UVM_NONE)
            
        endtask

        protected virtual task push_to_tx_fifo(md_item_mon item);
            sync_push_to_tx_fifo();
            tx_fifo.put(item);

            kill_set_tx_fifo_empty();

            inc_tx_lvl();

            `uvm_info("DEBUG",$sformatf("TX-FIFO push - new level:%0d pused_entry:%0d",
                                        reg_block.STATUS.TX_LVL.get_mirrored_value(),
                                        item.cov2str()),UVM_NONE)
        endtask
        /*-----------------------------------------------------------------------------------------*/

        protected virtual task build_buffer();
            forever begin
                algn_vif vif;
                vif = env_config.get_vif();

                if((buffer.sum() with {item.data.size()} ) <= reg_block.CTRL.SIZE.get_mirrored_value()) begin
                    md_item_mon item;
                    pop_from_rx_fifo(item);
                    buffer.push_back(item);
                end
                else begin
                    @(posedge vif.clk);
                end
            end
        endtask

        protected virtual function void split(int unsigned unm_bytes, md_item_mon item, ref md_item_mon item[$]);
            if(num_bytes == 0 || num_bytes >= item.size()) begin
                `uvm_fatal("ISSUE","can't split the item")
            end
            
            for(int i = 0; i < 2 ; i++) begin
                md_item_mon splitted_item = md_item_mon::type_id::create("splitted_item");

                if(i == 0) begin
                    splitted_item.offset = item.offset;
                    for(int j = 0 ; j < num_bytes ; j++) begin
                        splitted_item.push_back(item.data[j]);
                    end
                
                end
                else begin
                    splitted_item.offset = item.offset + num_bytes;
                    for(int j = num_bytes; j<item.data.size(); j++) begin
                        splitted_item.push_back(item.data[j]);
                    end
                end
                splitted_item.prev_item_delay = item.prev_item_delay;
                splitted_item.length = item.length;
                splitted_item.response = item.response;

                void'(splitted_item.begin_tr(item.get_begin_time()));

                if(item.is_active()) begin
                    splitted_item.end_tr(item.get_end_time());
                end
                items.push_back(splitted_item);
            end

        endfunction

        protected virtual task tx_ctrl();
            md_item_mon item;

            forever begin
                pop_from_tx_fifo();

                port_out_tx.write(item);

                tx_complete.wait_trigger();
            end

        endtask

        proteccted virtual task align();
            algn_vif vif = env_config.get_vif();
            
            forever begin
            ctrl_size = reg_block.CTRL.SIZE.get_mirrored_value();
            ctrl_offset = reg_block.CTRL.OFFSET.get_mirrored_value();
            
            uvm_wait_for_nba_region();

            if(ctrl_size <= (buffer.sum() with item.data.size()))begin
                while (ctrl_size <= (buffer.sum() with item.data.size())) begin
                    md_item_mon tx_item = md_item_mon::type_id::create("tx_item",this);

                    tx_item.offset = ctrl_offset;

                    void'(tx_item.begin_tr(buffer[0].get_begin_time()));

                    while (tx_item.data.size()!=ctrl_size) begin
                        md_item_mon buffer_item = buffer.pop_front();

                        if(tx_item.data.size() + buffer_item.data.size() <= ctrl_size) begin
                
                            foreach(buffer_item.data[idx]) begin
                              tx_item.data.push_back(buffer_item.data[idx]);
                            end
                            
                            if(tx_item.data.size() == ctrl_size) begin
                              tx_item.end_tr(buffer_item.get_end_time());
                              
                              push_to_tx_fifo(tx_item);
                            end
                        end 
                        else begin
                            int unsigned num_bytes_needed = ctrl_size - tx_item.data.size();
                            
                            cfs_md_item_mon splitted_items[$];
                            
                            split(num_bytes_needed, buffer_item, splitted_items);
                            
                            buffer.push_front(splitted_items[1]);
                            buffer.push_front(splitted_items[0]);

                            begin
                                split_info info = split_info::type_id::create("info");

                                info.ctrl_offset = ctrl_offset;
                                info.ctrl_size = ctrl_size;
                                info.md_offset = buffer_item.offset;
                                info.md_size = buffer_item.data.size();
                                info.num_bytes_neede = num_bytes_neede;

                                port_out_split_info.write(info);
                            end
                          end
                    end

                      
                end
            end
                    else begin
                      @(posedge vif.clk);
                    end
            end
        endtask

        
        /* -------------- Kill processes functions -------------------------------*/
        virtual function void kill_process(ref process p);
            if(p != null) begin
                p.kill();

                p = null;
            end

        endfunction

        protected virtual function void kill_set_rx_fifo_full();
            fork
                begin
                    uvm_wait_for_nba_region();

                    kill_process(process_set_rx_fifo_full);
                end    
            join_none

        endfunction

        protected virtual function void kill_set_rx_fifo_empty();
            fork
                begin
                    uvm_wait_for_nba_region();

                    kill_process(process_set_rx_fifo_empty);
                end    
            join_none
        endfunction

        protected virtual function void kill_set_tx_fifo_full();
            fork
                begin
                    uvm_wait_for_nba_region();

                    kill_process(process_set_tx_fifo_full);
                end    
            join_none
        endfunction

        protected virtual function void kill_set_tx_fifo_empty();
            fork
                begin
                    uvm_wait_for_nba_region();

                    kill_process(process_set_tx_fifo_empty);
                end    
            join_none
        endfunction
        
         /* ------------------------------- Setting IRQ functions ---------------------------------------*/
        protected virtual function void set_max_drop();
            void'(reg_block.IRQ.MAX_DROP.predict(1));

            `uvm_info("DEBUG", $sformatf("Drop counter reached max value - %0s: %0d",
                                reg_block.IRQEN.MAX_DROP.get_full_name(),
                                reg_block.IRQEN.MAX_DROP.get_mirrored_value()), UVM_NONE)

            if(reg_block.IRQEN.MAX_DROP.get_mirrored_value() == 1) begin
                exp_irq = 1;
            end
        endfunction

        protected virtual function void set_rx_fifo_full();
            fork
                begin

                    process_set_rx_fifo_full = process::self();

                    repeat(2) begin 
                        uvm_wait_for_nba_region(2);
                    end

                    void'(reg_block.IRQ.RX_FIFO_FULL.predict(1));

                    `uvm_info("DEBUG", $sformatf("RX FIFO became full - %0s: %0d",
                                        reg_block.IRQEN.RX_FIFO_FULL.get_full_name(),
                                        reg_block.IRQEN.RX_FIFO_FULL.get_mirrored_value()), UVM_NONE)

                    if(reg_block.IRQ.RX_FIFO_FULL.get_mirrored_value() == 1) begin
                        exp_irq = 1;
                    end

                    process_set_rx_fifo_full = null;
                end
            join_none
            
        endfunction

        protected virtual function void set_rx_fifo_empty();
            fork
                begin 
                    process_set_rx_fifo_empty = process::self();

                    repeat(2) begin
                        uvm_wait_for_nba_region();
                    end

                    void'(reg_block.IRQ.RX_FIFO_EMPTY.predict(1));

                    `uvm_info("DEBUG", $sformatf("RX FIFO became empty - %0s: %0d",
                                        reg_block.IRQEN.RX_FIFO_EMPTY.get_full_name(),
                                        reg_block.IRQEN.RX_FIFO_EMPTY.get_mirrored_value()), UVM_NONE)

                    if(reg_block.IRQEN.RX_FIFO_EMPTY.get_mirrored_value() == 1) begin
                        exp_irq = 1;
                    end
                end
            join_none
            
        endfunction

        protected virtual function void set_tx_fifo_empty();
            fork
                begin

                    process_set_tx_fifo_empty = process::self();

                    repeat(2) begin
                        uvm_wait_for_nba_region();
                    end

                    void'(reg_block.IRQ.TX_FIFO_EMPTY.predict(1));

                    `uvm_info("DEBUG", $sformatf("TX FIFO became empty - %0s: %0d",
                                        reg_block.IRQEN.TX_FIFO_EMPTY.get_full_name(),
                                        reg_block.IRQEN.TX_FIFO_EMPTY.get_mirrored_value()), UVM_NONE)

                    if(reg_block.IRQEN.TX_FIFO_EMPTY.get_mirrored_value() == 1) begin
                        exp_irq = 1;
                    end
                    process_set_tx_fifo_empty = null;
                end
            join_none
        endfunction

        protected virtual function void set_tx_fifo_full();
            fork
                begin
                    process_set_tx_fifo_full = process::self();

                    repeat(2) begin
                        uvm_wait_for_nba_region();
                    end

                    void'(reg_block.IRQ.TX_FIFO_FULL.predict(1));

                    `uvm_info("DEBUG", $sformatf("TX FIFO became full - %0s: %0d",
                                        reg_block.IRQEN.TX_FIFO_FULL.get_full_name(),
                                        reg_block.IRQEN.TX_FIFO_FULL.get_mirrored_value()), UVM_NONE)

                    if(reg_block.IRQ.RX_FIFO_FULL.get_mirrored_value() == 1) begin
                        exp_irq = 1;
                    end
                    process_set_tx_fifo_full = null;
                end
            join_none
        endfunction

         /* ------------------------------- sync functions ---------------------------------------*/
        protected virtual task sync_push_to_rx_fifo();
            algn_vif vif = env_config.get_vif();
            
            fork
                begin
                    fork
                        begin
                            @(posedge vif.clk iff (vif.rx_fifo_push));
                        end

                        begin
                            repeat(10) begin
                                @(posedge vif.clk iff(reg_block.STATUS.RX_LVL.get_mirrored_value() < rx_fifo.size()));
                            end

                            `uvn_warning("DUT-WARNING", "RX-FIFO push did ot syncrhonize with RTL")

                        end
                    join_any
                    
                    disable fork;
                end
            join
        endtask

        protected virtual task sync_push_to_tx_fifo();
            algn_vif vif = env_config.get_vif();
                        
                fork
                    begin
                        fork
                            begin
                                @(posedge vif.clk iff (vif.tx_fifo_push));
                            end

                            begin
                                repeat(10) begin
                                    @(posedge vif.clk iff(reg_block.STATUS.TX_LVL.get_mirrored_value() < tx_fifo.size() ));
                                end

                                `uvn_warning("DUT-WARNING", "TX-FIFO push did ot syncrhonize with RTL")

                            end
                        join_any
                        
                        disable fork;
                    end
                join
        endtask

        protected virtual task sync_pop_from_rx_fifo();
            algn_vif vif = env_config.get_vif();
                
            fork
                begin
                    fork
                        begin
                            @(posedge vif.clk iff (vif.rx_fifo_pop));
                        end

                        begin
                            repeat(10) begin
                                @(posedge vif.clk iff(reg_block.STATUS.RX_LVL.get_mirrored_value() > 0   && reg_block.STATUS.TX_LVL.get_mirrored_value < tx_fifo.size() ));
                            end

                            `uvn_warning("DUT-WARNING", "RX-FIFO pop did ot syncrhonize with RTL")

                        end
                    join_any
                    
                    disable fork;
                end
            join

        endtask

        protected virtual task sync_pop_from_tx_fifo();
            algn_vif vif = env_config.get_vif();
                    
            fork
                begin
                    fork
                        begin
                            @(posedge vif.clk iff (vif.tx_fifo_pop));
                        end

                        begin
                            repeat(200) begin
                                @(posedge vif.clk iff(reg_block.STATUS.TX_LVL.get_mirrored_value() > 0 ));
                            end

                            `uvn_warning("DUT-WARNING", "TX-FIFO pop did ot syncrhonize with RTL")

                        end
                    join_any
                    
                    disable fork;
                end
            join

        endtask
        /*------------------------------------------------------------------------------------*/
        protected virtual task send_exp_irq();
            algn_vif vif = env_config.get_vif();

            forever begin
                @(negedge vif.clk) begin
                    if(exp_irq == 1) 
                        port_out_irq.write(1);

                        exp_irq = 0;
                end
            end
        endtask

        /* ------------------------------- nb functions ---------------------------------------*/

        local virtual function void push_to_rx_fifo_nb(md_item_mon item);
            if(process_push_to_rx_fifo != null) begin
                `uvm_fatal("ISSUE", "Can not start two instances of push_to_rx_fifo() tasks")
            end
            fork 
                begin
                    process_push_to_rx_fifo = process::self();

                    push_to_rx_fifo(item);

                    process_push_to_rx_fifo = null;
                end 
            join_none
        endfunction

        local virtual function void build_buffer_nb(md_item_mon item);
            if(process_build_buffer != null) begin
                `uvm_fatal("ISSUE", "Can not start two instances of build_buffer() tasks")
            end
            fork 
                begin
                    process_build_buffer = process::self();

                    build_buffer();

                    process_build_buffer = null;
                end 
            join_none
        endfunction

        local virtual function void align_nb();
            if(process_align != null) begin
                `uvm_fatal("ISSUE",  "can't start two instances of align() tasks")
            end
            fork
                begin
                    process_align = process::self();

                    align();

                    process_align = null;
                end
            join_none
        endfunction

        local virtual function void tx_ctrl_nb();
            if(tx_ctrl_nb != null) begin
                `uvm_fatal("ISSUE",  "can't start two instances of tx_ctrl() tasks")
            end
            fork
                begin
                    process_tx_ctlr = process::self();

                    tx_ctrl();

                    process_tx_ctlr = null;
                end
            join_none
        endfunction

        local virtual function void send_exp_irq_nb();
            if(process_send_exp_irq != null) begin
                `uvm_fatal("ISSUE", "Can not start two instances of send_exp_irq() tasks")
            end

            fork 
                begin
                    process_send_exp_irq = process::self();

                    send_exp_irq();

                    process_send_exp_irq = null;
                end
            join_none
        endfunction
        /* ---------------------- Handle reset function ----------------------------------*/
        virtual function void handle_reset(uvm_phase phase);
            reg_block.reset("HARD");

            kill_process(process_push_to_rx_fifo);
            kill_process(process_build_buffer);
            kill_process(process_align);
            kill_process(process_tx_ctlr);
            kill_process(process_set_rx_fifo_empty);
            kill_process(process_set_rx_fifo_full);
            kill_process(process_set_tx_fifo_empty);
            kill_process(process_set_tx_fifo_full);
            kill_process(process_send_exp_irq);

            exp_irq = 0;
            tx_complete.reset();

            rx_fifo.flush();
            tx_fifo.flush();

            buffer = {};
            build_buffer_nb();
            align_nb();
            tx_ctrl_nb();
            send_exp_irq_nb();
        endfunction

        //Function to determine if the model is empty
        virtual function bit is_empty();
            if(rx_fifo.used() != 0) begin
                return 0;
            end 
            
            if(tx_fifo.used() != 0) begin
                return 0;
            end 
            
            if(buffer.size() != 0) begin
                return 0;
            end 
            
            return 1;
        endfunction

    endclass

`endif 