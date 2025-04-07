`ifndef MD_AGENT_CONFIG_SV
    `define MD_AGENT_CONFIG_SV

    class md_agent_config#(int unsigned DATA_WIDTH = 32) extends uvm_ext_agent_config#(.VIRTUAL_IF(virtual md_if#(DATA_WIDTH)));

        typedef virtual md_if#(DATA_WIDTH) md_vif;

        local int unsigned stuck_threshold;

        local time sample_delay_start_tr;

        `uvm_component_param_utils(md_agent_config#(DATA_WIDTH))

        function new (string name = "md_agent_config", uvm_component parent = null);
            super.new(name,parent);
            stuck_threshold = 100;
            sample_delay_start_tr = 1ns;
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                @(vif.has_checks);
                if(vif.has_checks != get_has_checks()) begin
                    `uvm_error("MD_CONFIG", "MD VIF has_checks is out of sync with the configuration object");
                end
            end
        endtask

        // Getter for stuck_threshold
        virtual function int unsigned get_stuck_threshold();
            return stuck_threshold;
        endfunction

        // Setter for stuck_threshold
        virtual function void set_stuck_threshold(int unsigned value);
            stuck_threshold = value;
        endfunction

        // Setter for md_vif
        virtual function void set_vif(md_vif value);
            super.ser_vif(value)
            set_has_checks(get_has_checks());
        endfunction


        // Setter for has_checks
        virtual function void set_has_checks(bit value);
            super.set_has_checks(value);

            // Sync the value with the VIF
            if (vif != null) begin
                vif.has_checks = has_checks;
            end
        endfunction

        virtual task wait_reset_start();
            if(vif.reset_n !==0) begin
                @(negedge vif.reset_n); 
            end
        endtask

        virtual task wait_reset_end();
            while(vif.reset_n === 0) begin
                @(posedge vif.clk);
            end
        endtask

        // Getter for sample_delay_start_tr = 1ns;
        virtual function time get_sample_delay_start_tr();
            return sample_delay_start_tr;
        endfunction

        // Setter for sample_delay_start_tr
        virtual function void set_sample_delay_start_tr(time value);
            sample_delay_start_tr = value;
        endfunction

    endclass

`endif 