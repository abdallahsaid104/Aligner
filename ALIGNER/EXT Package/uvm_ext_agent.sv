`ifndef UVM_EXT_AGENT_SV
    `define UVM_EXT_AGENT_SV

    class uvm_ext_agent#(type VIRTUAL_IF = int, type ITEM_DRV = uvm_sequence_item, type ITEM_MON = ITEM_DRV) extends uvm_agent implements uvm_ext_reset_handler;
        
        uvm_ext_agent_config#(VIRTUAL_IF) agent_config;

        uvm_ext_driver#(VIRTUAL_IF,ITEM_DRV) driver;

        uvm_ext_monitor#(VIRTUAL_IF,ITEM_MON) monitor;

        uvm_ext_sequencer#(ITEM_DRV) sequencer;

        uvm_ext_coverage#(VIRTUAL_IF,ITEM_MON) coverage;

        `uvm_component_param_utils(uvm_ext_agent#(VIRTUAL_IF,ITEM_DRV,ITEM_MON))

        function new(string name = "uvm_ext_agent",uvm_component parent = null);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_cofig_db#(uvm_ext_agent_config#(VIRTUAL_IF))::get(this, "","agent_config", agent_config)) begin
                agent_config = uvm_ext_agent_config#(VIRTUAL_IF)::type_id::create("agent_config", this);
            end
            monitor = uvm_ext_monitor#(VIRTUAL_IF,ITEM_MON)::type_id::create("monitor", this);
            if(agent_config.get_active_passive() == UVM_ACTIVE) begin
                driver = uvm_ext_driver#(VIRTUAL_IF,ITEM_DRV)::type_id::create("driver", this);
                sequencer = uvm_ext_sequencer#(ITEM_DRV)::type_id::create("sequencer", this);
            end
            if(agent_config.get_has_coverage()) begin
                coverage = uvm_ext_coverage#(VIRTUAL_IF,ITEM_MON)::type_id::create("coverage", this);
            end
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            VIRTUAL_IF vif;
            super.connect_phase(phase);

            if(!uvm_config_db#(VIRTUAL_IF)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NO_VIF", "Couldn't get the VIF from the database")
            end
            else begin
                agent_config.set_vif(vif);
            end
            monitor.agent_config = agent_config;
            if(monitor.get_has_coverage()) begin
                monitor.mon_port.connect(coverage.coverage_port);
            end

            if(agent_config.get_active_passive() == UVM_ACTIVE) begin
                driver.seq_item_port.connect(sequencer.seq_item_export);
                driver.agent_config = agent_config;
            end
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                wait_reset_start();
                handle_reset(phase);
                wait_reset_end();
            end
        endtask

        virtual function void handle_reset(uvm_phase phase);
            uvm_component children[$];
            get_children(children);
            
            foreach(children[idx]) begin
                uvm_ext_reset_handler reset_handler;

                if($cast(reset_handler, children[idx])) begin
                    reset_handler.handle_reset(phase)
                end
            end
        endfunction

        virtual task wait_reset_start();
            agent_config.wait_reset_start();
        endtask

        virtual task wait_reset_end();
            agent_config.wait_reset_end();
        endtask

    endclass

`endif 