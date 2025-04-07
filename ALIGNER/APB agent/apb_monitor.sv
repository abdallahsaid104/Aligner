`ifndef APB_MONITOR_SV
    `define APB_MONITOR_SV

    class apb_monitor extends uvm_ext_monitor#(.VIRTUAL_IF(apb_vif), .ITEM_MON(apb_item_mon));

        apb_agent_config agent_config;

        // Register the apb monitor class with the factory
        uvm_object_utils(apb_monitor);

        function new (string name = "apb_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        virtual function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);
            if($cast(agent_config, super.agent_config) == 0) begin
                `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Could not cast %0s to %0s", 
                   super.agent_config.get_type_name(), apb_agent_config::type_id::type_name))
              end
        endfunction

        virtual task collect_transaction();
            apb_vif vif = agent_config.get_vif();
            item = apb_item_mon::type_id::create("item");

            // 1- collect the prev_item_delay (post_drv_delay for previous transaction + pre_drv_delay for the present transaction) 
            //    and waitong for the next transaction
            while(vif.psel !== 1) begin
                @(posedge vif.pclk);
                item.prev_item_delay ++;
            end

            // 2- collect the addr
            item.addr = vif.addr;

            // 3- collect the direction
            item.direction = apb_direction'(vif.pwrite);

            // 4- collect the data if the direction is write     
            if(item.direction == APB_WRITE) begin
                item.data = vif.pwdata;
            end

            // 5- collect the length of the transaction
            item.length = 1;
            @(posedge vif.pclk);
            item.length ++;

            while(vif.pready !== 1) begin
                @(posedge vif.pclk);
                item.length ++;
                if(agent_config.get_has_checks()) begin
                    if(item.length >= agent_config.get_stuck_threshold()) begin
                        `uvm_error("APB_MONITOR", $sformatf("Transaction reached tha stuck stuck_threshold value %0d", item.length));
                    end
                end
            end

            // 6- collect the response (APB_OK / APB_ERR)
            item.response = apb_response'(vif.pslverr);

            // 7- Read the data if the direction is read
            if(item.direction == APB_READ) begin
                item.data = vif.prdata;
            end

            // 8- Prodcast the item
            mon_port.write(item);

            `uvm_info("APB_MONITOR", $sformatf("Collecting \"%0s\": %0s", item.get_full_name(), item.conv2str()),UVM_NONE)
            
        endtask

    endclass
`endif 