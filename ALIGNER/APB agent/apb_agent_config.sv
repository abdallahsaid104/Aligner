///////////////////////////////////////////////////////////////////////////////
// File:        apb_agent_config.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: configuration class for apb agent.
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_AGENT_CONFIG_SV
    `define APB_AGENT_CONFIG_SV

    class apb_agent_config extends uvm_ext_agent_config#(.VIRTUAL_IF(apb_vif));

        // Register the APB configuration class with the factory
        uvm_copmonent_utils(apb_agent_config);

        // Number of cycles after which an APB transfer is considered stuck and an eror is triggered
        local int unsigned stuck_threshold;

        function new (string name = "apb_agent_config", uvm_component parent = null);
            super.new(name,parent);
            stuck_threshold = 100;
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                @(vif.has_checks);
                if(vif.has_checks != get_has_checks()) begin
                    `uvm_error("APB_CONFIG", "APB VIF has_checks is out of sync with the configuration object");
                end
            end
        endtask

        // Getter for stuck_threshold
        virtual function int unsigned get_stuck_threshold();
            return stuck_threshold;
        endfunction

        // Setter for stuck_threshold
        virtual function void set_stuck_threshold(int unsigned value);
            if(value <= 2) begin
                `uvm_error("APB_CONFIG", "Tried to set the stuck_threshold of APB transaction to %0d but the minimum length of the APB transaction is 2 cycles",value);
                return;
            end

            stuck_threshold = value;
        endfunction

        //Setter for the APB virtual interface
        virtual function void set_vif(apb_vif value);
            super.set_vif(value);
            set_has_checks(get_has_checks());
        endfunction

        //Setter for the has_checks control field
        virtual function void set_has_checks(bit value);
            super.set_has_checks(value);

            if(vif != null) begin
                vif.has_checks = has_checks;
            end
        endfunction

        virtual task wait_reset_start();
            if(vif.preset_n !==0) begin
                @(negedge vif.preset_n); 
            end
        endtask

        virtual task wait_reset_end();
            while(vif.preset_n === 0) begin
                @(posedge vif.pclk);
            end
        endtask

    endclass
`endif 