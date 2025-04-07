`ifndef UVM_EXT_AGENT_CONFIG_SV
    `define UVM_EXT_AGENT_CONFIG_SV

    class  uvm_ext_agent_config#(type VIRTUAL_IF = int) extends uvvm_component;

        protected VIRTUAL_IF vif;

        protected uvm_active_passive_enum active_passive;

        protected bit has_coverage;

        protected bit has_checks;

        `uvm_component_param_utils(uvm_ext_agent_config#(VIRTUAL_IF))

        function new(string name = "uvm_ext_agent_config", uvm_component parent = null);
            super.new(name, parent);
            active_passive = UVM_ACTIVE;
            has_checks = 1;
            has_coverage = 1;
        endfunction

        virtual function void start_of_simulation_phase(uvm_phase phase);
            super.start_of_simulation_phase(phase);
            if(get_vif == null) begin
                `uvm_fatal("ISSUE", " The virtual interface is not configured at the \" Start of Simulation\" phase")
            end
        endfunction

        // Getter for vif
        virtual function VIRTUAL_IF get_vif();
            return vif;
        endfunction

        // Setter for vif

        virtual function void set_vif(VIRTUAL_IF value);
            if(vif == null) begin
                vif = value;
            end
            else begin
                `uvm_fatal("ISSUE", "Trying to set the Virtuak interface more than once")
            end
        endfunction

        // Getter for active_passive
        virtual function uvm_active_passive_enum get_active_passive();
            return active_passive;
        endfunction

        // Setter for active_passive
        virtual function void set_active_passive(uvm_active_passive_enum mode);
            active_passive = mode;
        endfunction

        // Getter for has_checks
        virtual function bit get_has_checks();
            return has_checks;
        endfunction

        // Setter for has_checks
        virtual function void set_has_checks(bit value);
            has_checks = value;
        endfunction

        // Getter for has_coverage
        virtual function bit get_has_coverage();
            return has_coverage;
        endfunction

        // Setter for has_coverage
        virtual function void set_has_coverage(bit value);
            has_coverage = value;   
        endfunction

        virtual task wait_reset_end();
            `uvm_fatal("ISSUE", "One must implement wait_reset_end() task")
        endtask

        virtual task wait_reset_start();
            `uvm_fatal("ISSUE", "One must implement wait_reset_start() task")
        endtask

    endclass

`endif 