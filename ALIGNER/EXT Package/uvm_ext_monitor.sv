`ifndef UVM_EXT_MONITOR_SV
    `define UVM_EXT_MONITOR_SV

    class uvm_ext_monitor#(type VIRTUAL_IF = int , type ITEM_MON = uvm_sequence_item) extends uvm_monitor implements uvm_ext_reset_handler;

        // configuration handle
        uvm_ext_agent_config#(VIRTUAL_IF) agent_config;

        // Analysis port for prodcasing the items
        uvm_analysis_port #(ITEM_MON) mon_port;

        // Pointer the process associated with collect_transactions() task
        protected process process_collect_transactions;

        uvm_component_param_utils(uvm_ext_monitor#(VIRTUAL_IF, ITEM_MON))

        function new(string name = "uvm_ext_monitor",uvm_component parent = null);
            super.new(name,parent);
            mon_port = new("mon_port", this);
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                fork 
                    begin
                        wait_reset_end();
                        collect_transactions();
                        
                        disable fork;
                    end
                join
            end    
        endtask

        // Task to collect all the items
        protected virtual task collect_transactions();
            fork
                begin
                    process_collect_transactions = process::self();

                    forever begin
                        collect_transaction();
                    end
                end
            join
            
        endtask

        protected virtual task void collect_transaction();
            `uvm_fatal("ISSUE", "One must implement collect_transaction() task ")
        endtask

        virtual task wait_reset_end();
            agent_config.wait_reset_end();
        endtask

        virtual function void handle_reset(uvm_phase phase);
             /*
                IF there is any process of transaction when reset is done, terminate this process.
            */

            if(process_drive_transactions != null) begin
                process_drive_transactions.kill();
                
                process_drive_transactions =  null;
            end
        endfunction


    endclass

`endif 