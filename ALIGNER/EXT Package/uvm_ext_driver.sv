`ifndef UVM_EXT_DRIVER_SV
    `define UVM_EXT_DRIVER_SV

    class uvm_ext_driver#(type VIRTUAL_IF = int, type ITEM_DRV = uvm_sequence_item) extends uvm_driver#(.REQ(ITEM_DRV)) implements uvm_ext_reset_handler;

        uvm_ext_agent_config#(VIRTUAL_IF) agent_config;
        
        protected process process_drive_transactions;

        uvm_component_param_utils(uvm_ext_driver#(VIRTUAL_IF,ITEM_DRV))

        function new (string name = "uvm_ext_driver", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                fork
                    begin
                        wait_reset_end();
                        drive_transactions()

                    disable fork
                    end
                join
            end
        endtask

        virtual task drive_transactions()
        fork
            begin
                process_drive_transactions = process::self();
                forever begin
                    ITEM_DRV item;
                    seq_item_port.get_next_item(item);

                    drive_transaction(item);

                    seq_item_port.item_done();
                end
            end
        join

        endtask

        virtual task wait_reset_end()
            md_config.wait_reset_end();
        endtask


        virtual function void handle_reset(uvm_phase phase);

            if(process_drive_transactions ! = null) begin
                process_drive_transactions.kill();

                process_drive_transactions = null;
            end

        endfunction

        
        protected virtual task drive_transaction(ITEM_DRV item);
            `uvm_fatal("MD_DRIVER", " Implement drive_transaction()")
        endtask

    endclass

`endif 