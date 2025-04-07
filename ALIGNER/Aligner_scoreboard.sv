`ifndef ALIGNER_SCOREBOARD_SV
    `define ALIGNER_SCOREBOARD_SV

    `uvm_analysis_imp_decl(_in_model_rx)
    `uvm_analysis_imp_decl(_in_model_tx)
    `uvm_analysis_imp_decl(_in_model_irq)
    `uvm_analysis_imp_decl(_in_agent_rx)
    `uvm_analysis_imp_decl(_in_aget_tx)

    class Aligner_scoreboard extends uvm_component implemets uvm_ext_reset_handler;

        env_config env_config;

        uvm_analysis_imp_in_model_rx#(md_response, Aligner_scoreboard) port_in_model_rx;

        uvm_analysis_imp_in_model_tx#(md_item_mon, Aligner_scoreboard) port_in_model_tx;

        uvm_analysis_imp_in_model_ire#(bit, Aligner_scoreboard) port_in_model_irq;

        uvm_analysis_imp_in_agent_rx#(md_item_mon , Aligner_scoreboard) port_in_agent_rx;

        uvm_analysis_imp_in_agent_tx#(md_item_mon , Aligner_scoreboard) port_in_agent_tx;

        protected md_response exp_rx_responses[$];

        protected md_item_mon exp_tx_items[$];

        protected bit exp_irqs[$];

        local process process_exp_rx_response_watchdog[$];

        local process process_exp_tx_item_watchdog[$];

        local process process_exp_irq_watchdog[$];

        local process process_rcv_irq;

        `uvm_component_utils(Aligner_scoreboard);
    
        function new(string name = "Aligner_scoreboard", uvm_component = null);
            super.new(name, parent);
            port_in_model_rx = new("port_in_model_rx", this);
            port_in_model_tx = new("port_in_model_tx", this);
            port_in_model_irq = new("port_in_model_irq", this);
            port_in_agent_rx = new("port_in_agent_rx", this);
            port_in_agent_tx = new("port_in_agent_tx", this);
        endfunction

        virtual task exp_rx_response_watchdog(md_response response);
            algn_vif vif = env_config.get_vif();
            int unsigned threshold = env_config.get_rx_exp_response_threshold();
            time start_time = $time();

            repeat(threshold) begin
                @(posedge vif.clk);
            end

            if(env_config.get_has_checks() == 1) begin
                `uvm_fatal("ISSUE", 
                            $sformatf("The expected response:%0s expected from time:%0t was not received after %0d cycles ",
                                        response.name(), start_time, threshold));
            end

        endtask

        virtual task exp_tx_item_watchdog(md_item_mon item_mon);
            algn_vif vif = env_config.get_vif();
            int unsigned threshold = env_config.get_tx_exp_item_threshold();
            time start_time = $time();

            repeat(threshold) begin
                @(posedge vif.clk);
            end

            if(env_config.get_has_checks() == 1) begin
                `uvm_fatal("ISSUE", 
                            $sformatf("The TX item expected from time %0t, was not received after %0d clock cycles - item: %0s",
                                        start_time, threshold, item_mon.cov2str()));
            end

        endtask

        virtual task exp_irq_watchdog(bit irq);
            algn_vif vif = env_config.get_vif();
            int unsigned threshold = env_config.get_exp_irq_threshold();
            time start_time = $time();

            repeat(threshold) begin
                @(posedge vif.clk);
            end

            if(env_config.get_has_checks() == 1) begin
                `uvm_fatal("ISSUE", 
                            $sformatf("The IRQ expected from time %0t, was not received after %0d clock cycles",
                                        start_time, threshold));
            end

        endtask

        local virtual function void exp_rx_response_watchdog_nb(md_response response);
            fork
                begin
                    process p = process::self();

                    process_exp_rx_response_watchdog.push_back(p);

                    exp_rx_response_watchdog(response);

                    if(process_exp_rx_response_watchdog.size() == 0) begin
                        `uvm_fatal("ISSUE", "At the end of task exp_rx_response_watchdog() the queue of processes process_exp_rx_response_watchdog is empty")
                    end

                    void'(process_exp_rx_response_watchdog.pop_front());
                end
            join_none
        endfunction

        local virtual function void exp_tx_item_watchdog_nb(md_item_mon item_mon);
            fork
                begin
                    process p = process::self();

                    process_exp_tx_item_watchdog.push_back(p);

                    exp_tx_item_watchdog(item_mon);

                    if(process_exp_tx_item_watchdog.size() == 0) begin
                        `uvm_fatal("ISSUE", "At the end of task exp_tx_item_watchdog() the queue of processes process_exp_tx_item_watchdog is empty")
                    end

                    void'(process_exp_tx_item_watchdog.pop_front());
                end
            join_none
        endfunction

        local virtual function void exp_irq_watchdog_nb(bit irq);
            fork
                begin
                    process p = process::self();

                    process_exp_irq_watchdog.push_back(p);

                    exp_irq_watchdog(irq);

                    if(process_exp_irq_watchdog.size() == 0) begin
                        `uvm_fatal("ISSUE", "At the end of task exp_irq_watchdog() the queue of processes process_exp_irq_watchdog is empty")
                    end

                    void'(process_exp_irq_watchdog.pop_front());
                end
            join_none
        endfunction

        protected virtual task rcv_irq();
            algn_vif vif = env_config.get_vif();
            forever begin
                @(posedge vif.clk iff  (vif.irq & vif.reset_n));
                    if(exp_irqs.size() == 0) begin
                        if(env_config.get_has_checks() == 1) begin
                            `uvm_error("DUT-ERROR", "Unexpected IRQ received")
                        end
                    end
                    else begin
                        void'(exp_irqs.pop_front());

                        process_exp_irq_watchdog[0].kill();

                        void'(process_exp_irq_watchdog.pop_front());
                    end
            end
        endtask

        local virtual function void rcv_irq_nb();
            if(process_rcv_irq != null) begin
                `uvm_fatal("ISSUE", "Can't start two instances of rcv_irq() task at the same time")
            end

            fork
                begin
                    process_rcv_irq = process::self();

                    rcv_irq();

                    process_rcv_irq = null;
                end
            join_none
        endfunction

        virtual function void handle_reset(uvm_phase phase);
          
            exp_rx_responses.delete();
            exp_tx_items.delete();
            exp_irqs.delete();

            kill_process_from_queue(process_exp_rx_response_watchdog);
            kill_process_from_queue(process_exp_tx_item_watchdog);
            kill_process_from_queue(process_exp_irq_watchdog);
            kill_process(process_rc_irq);

            rcv_irq_nb();

        endfunction

        virtual function void kill_process_from_queue(ref process process_queue[$]);
            while(process_queue.size() > 0 ) begin
                process_queue[0].kill();

                void'(process_queue.pop_front());
            end
        endfunction

        virtual function void kill_process(ref process p);
            if(p != null) begin
                p.kill();

                p = null;
            end
        endfunction

        virtual function void write_in_model_rx(md_response response);
            if(exp_rx_responses.size() >= 1) begin
                `uvm_error("ISSUE", 
                        $sformatf("There is something wrong as there are already %0d entries in exp_rx_response and just received one more",
                            exp_rx_responses.size()))
            end

            exp_rx_responses.push_back(response);

            exp_rx_response_watchdog_nb(response);

        endfunction

        virtual function void write_in_model_tx(md_item_mon item_mon);
            if(exp_tx_items.size() >= 1) begin
                `uvm_error("ISSUE", 
                        $sformatf("There is something wrong as there are already %0d entries in exp_rx_response and just received one more",
                            exp_tx_items.size()))
            end

            exp_tx_items.push_back(item_mon);

            exp_tx_item_watchdog_nb(item_mon);
        endfunction

        virtual function void write_in_model_irq(bit irq);
            if(exp_irqs.size() > = 5) begin
                `uvm_error("ISSUE",
                        $sformatf("There is something wrong as there are already %0d entries in exp_irqs and just received one more",
                            exp_irqs.size()))
            end
            exp_irqs.push_back(irq);

            exp_irq_watchdog_nb(irq);
        endfunction

        virtual function void write_in_agent_rx(md_item_mon item_mon);
            if(!item_mon.is_active()) begin
                md_response exp_response = exp_rx_responses.pop_front();

                process_exp_rx_response_watchdog[0].kill();

                void'(process_exp_rx_response_watchdog.pop_front());

                if(env_config.get_has_checks() == 1) begin
                    if(item_mon.response !=exp_response) begin
                        `uvm_fatal("DUT-ERROR", 
                                    $sformatf("Mismatch detected for RX response --> expected :%0s ,received:%0s , item:%0s",
                                                exp_response.name(), item_mon.response.name(), item_mon.cov2str()));
                    end
                end
            
            end

        endfunction

        virtual function void write_in_agent_tx(md_item_mon item_mon);
            if(!item_mon.is_active()) begin
                md_item_mon exp_item = exp_tx_items.pop_front();

                process_exp_tx_item_watchdog[0].kill();
        

                void'(process_exp_tx_item_watchdog.pop_front());

                if(env_config.get_has_checks() == 1) begin
                    if(item_mon.data !=exp_item.data) begin
                        `uvm_fatal("DUT-ERROR", 
                                    $sformatf("Mismatch detected for TX data --> expected :%0s ,received:%0s",
                                                exp_item.cov2str(), item_mon.cov2str()));
                    end

                    if(item_mon.offset !=exp_item.offset) begin
                        `uvm_fatal("DUT-ERROR", 
                                    $sformatf("Mismatch detected for TX offset --> expected :%0d ,received:%0d , item:%0s",
                                                exp_item.offset, item_mon.offset, item_mon.cov2str()));
                    end
                end
            end
        endfunction

    endclass
`endif