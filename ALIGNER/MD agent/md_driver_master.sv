`ifndef MD_DRIVER_MASTER_SV
    `define MD_DRIVER_MASTER_SV

    class md_driver_master#(int unsigned DATA_WIDTH = 32) extends md_driver#(.DATA_WIDTH(DATA_WIDTH), .ITEM_DRV(md_item_drv_master));
        `uvm_component_param_utils(md_driver_master#(DATA_WIDTH))

        typedef virtual md_if #(DATA_WIDTH) md_vif;

        function new (string name = "md_driver_master", uvm_component parent = null);
            super.new(name, parent)
        endfunction

        // Task to drive one item to MD protocol
        /*
            Driving one item:
            1- Wait for the pre_drive_delay
            2- valid is set to 1 after the pre_drv_delay
            3- Drive data , offset, size
            4- wait at-least 1 cycle.
            5- wait ready to be high.
            6- reset all values
            7- Waiting for the post_drive_delay
        */

        protected virtual task drive_transaction();
            md_item_drv_master item;

            md_vif vif = agent_config.get_vif();

            int unsigned data_size_in_bytes = DATA_WIDTH / 8;
            
            `uvm_info("MD_DRIVER_MASTER",$sformatf("Driving \" %0s \": %0s",item.get_full_name(),item.conv2str()),UVM_NONE)

            if(item.offset + item.data.size() > data_size_in_bytes) begin
                `uvm_fatal("ISSUE", "Trying to drive an item with invalid offset and bytes")
            end

            // 1 - Wait for the pre_drive_delay
            for (int i = 0 ; i < item.pre_drv_delay ; i++) begin
                @(posedge vif.clk);
            end

            // 2- valid is set to 1 after the pre_drv_delay
            vif.valid <= 1 ;

            // 3 - Drive data - offset - delay
            begin
                bit [DATA_WIDTH-1:0] data = 0;
                foreach (item.data[idx]) begin
                    bit [DATA_WIDTH-1:0] temp = item.data[idx] << ((item.offset + idx)*8);

                    data = data | temp;
                    
                end
                vif.data <= data;
            end
            vif.offset <= item.offset;
            vif.size <= item.data.size();
            
            // 4- Wait at-least one cycle.
            @(posedge vif.clk);

            // 5- Wait until ready is high
            while(vif.ready != 1) begin
                @(vif.clk);
            end
            
            // 6- Reset all values.
            vif.valid  <= 0;
            vif.data   <= 0;
            vif.offset <= 0;
            vif.size   <= 0;

            // 7- wait for post_drv_delay
            for(int i = 0; i<post_drv_delay; i++) begin
                @(posedge vif.clk );
            end
        endtask

        virtual function void handle_reset(uvm_phase phase)
            md_vif  vif = agent_config.get_vif();
            super.handle_reset(phase);

            vif.valid  <= 0;
            vif.data   <= 0;
            vif.offset <= 0;
            vif.size   <= 0;

        endfunction
    endclass

`endif  