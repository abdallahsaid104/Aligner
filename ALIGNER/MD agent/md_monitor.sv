`ifndef MD_MONITOR_SV
    `define MD_MONITOR_SV

    class md_monitor#(int unsigned DATA_WIDTH = 32) extends uvm_ext_monitor#(.VIRTUAL_IF(virtual md_if#(DATA_WIDTH)), .ITEM_MON(md_item_mon)); 
        
        typedef virtual md_if#(DATA_WIDTH) md_vif;

        md_agent_config#(DATA_WIDTH) agent_config;

        `uvm_component_PARAM_utils(md_monitor#(DATA_WIDTH))

        function new(string name = "md_monitor", uvm_component parent = null)
            super.new(name, parent);
        endfunction

        virtual function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);
            if($cast(agent_config, super.agent_config) == 0) begin
                `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Could not cast %0s to %0s", 
                   super.agent_config.get_type_name(), apb_agent_config::type_id::type_name))
              end
        endfunction

        protected virtual task collect_transaction()
            md_vif vif = agent_config.get_vif();

            int unsigned data_size_in_bytes = DATA_WIDTH / 8;

            md_item_mon item = md_item_mon#(DATA_WIDTH)::type_id::create("item");

            // Wait for start of transaction;
            #(agent_config.get_sample_delay_start_tr());
            while (vif.valid !==1) begin
                @(posedge vif.clk);
                item.prev_item_delay++;
                #(agent_config.get_sample_delay_start_tr());
            end
            
            // Sample offset
            item.offset =  vif.offset;

            // Sample data
            for(int i = 0 ; i < vif.size ; i++) begin
                item.data.push_back((vif.data >> (item.offset + i) * 8) &'8'hFF );
            end

            // Get the length of MD transaction and proadcast the transaction at the start of transaction.
            item.lenght = 1;

            // Detect the satart of the transaction and send it to item (to be used in conv2str())
            void'(begin_tr(item));

            mon_port.write(item);

            @(posedge vif.clk);

            while(posedge vif.ready !== 1) begin
                @(posedge vif.clk);
                    item.length++;
                
                if(agent_config.get_has_checks()) begin
                    if(item.length >= agent_config.get_stuck_threshold()) begin
                        `uvm_error("PROTOCOL_ERROR", $sformatf("The MD transfer reached the stuck threshold value of %0d", item.length))
                    end
                end
            end

            // Sample the response
            item.response = md_response'(vif.err)

            // Detect the end of transaction and send it to item (to be used in conv2str())
            end_tr(item);

            // Proadcast the transaction at the end of the transaction
            mon_port.write(item);

            `uvm_info("MD_MONITOR","monitor item : %0s ",item.conv2str(),UVM_NONE)
        endtask

    endclass

`endif 