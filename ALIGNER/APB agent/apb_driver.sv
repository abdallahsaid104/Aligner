`ifndef APB_DRIVER_SV
    `define APB_DRIVER_SV

    class apb_driver#(type ITEM_DRV = apb_item_drv) extends uvm_ext_driver#(.VIRTUAL_IF(apb_vif), .ITEM_DRV(ITEM_DRV)) 

        // Register the apb driver class with the factory
        uvm_object_utils(apb_driver#(ITEM_DRV));

        apb_agent_config agent_config;

        function new (string name = "apb_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        virtual function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);
            if($cast(agent_config, super.agent_config) == 0) begin
                `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Could not cast %0s to %0s", 
                   super.agent_config.get_type_name(), apb_agent_config::type_id::type_name))
              end
        endfunction

        // Task to drive one item on the APB bus
        /*
            Driving one item:
            1- Wait for the pre_drive_delay
            2- psel is set to 1 after the pre_drive_delay
            3- pwrite is set to the direction of the item (read = 0 , write = 1)
            4- paddr is set to the address of the item
            5- if the direction is write, pwdata is set to the data of the item
            6- penable is set to 1 after one cycle
            7- Waiting atleast one cycle after penable is set to 1
            8- Waiting untill pready is high
            9- psel, penable, pwrite, paddr, pwdata are set to 0
            10- Waiting for the post_drive_delay
        */
        protected virtual task drive_transaction();
            apb_vif vif = agent_config.get_vif();
            `uvm_info("APB_DRIVER", $sformatf("Driving \"%0s\": %0s", item.get_full_name(), item.conv2str()),UVM_NONE)

            // 1- Waiting for the pre_drive_delay
            for(int i = 0 ; i < item.pre_drive_delay; i++) begin
                @(posedge vif.pclk);
            end

            // 2- psel is set to 1 after the pre_drive_delay
            vif.psel <= 1;

            // 3- pwrite is set to the direction of the item (read = 0 , write = 1)
            vif.pwrite <= bit'(item.direction);

            // 4- paddr is set to the address of the item
            vif.paddr <= item.addr;

            // 5- if the direction is write, pwdata is set to the data of the item
            if(item.direction == APB_WRITE) begin
                vif.pwdata <= item.data;
            end
            
            // 6- penable is set to 1 after one cycle
            @(posedge vif.pclk);
            vif.penable <= 1;

            // 7- Waiting atleast one cycle after penable is set to 1
            @(posedge vif.pclk);
            
            // 8- Waiting untill pready is high
            while(vif.pready == 0) begin
                @(posedge vif.pclk);
            end

            // 9- psel, penable, pwrite, paddr, pwdata are set to 0
            vif.psel <= 0;
            vif.penable <= 0;
            vif.pwrite <= 0;
            vif.paddr <= 0;
            vif.pwdata <= 0;

            // 10- Waiting for the post_drive_delay
            for(int i = 0 ; i < item.post_drive_delay; i++) begin
                @(posedge vif.pclk);
            end 

        endtask

        virtual function void handle_reset(uvm_phase phase);
            apb_vif vif = agent_config.get_vif();

            sueper.handle_reset(phase);
           
            // Re-initialaize the signals.
            vif.psel <= 0;
            vif.penable <= 0;
            vif.pwrite <= 0;
            vif.paddr <= 0;
            vif.pwdata <= 0;
        
        endfunction

    endclass
`endif 