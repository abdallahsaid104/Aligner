`ifndef ALIGNER_ENV_CONFIG_SV
    `define ALIGNER_ENV_CONFIG_SV

    class Aligner_env_config extends uvm_component;

        protected algn_vif vif;

        local bit has_checks;

        local bit has_coverage;

        local int unsigned algn_data_width;

        local int unsigned rx_exp_response_threshold;

        local int unsigned tx_exp_item_threshold;

        local int unsigned exp_irq_threshold;

        `uvm_copmonent_utils(Aligner_env_config)

        function new(string name = "Aligner_env_config", uvm_component parent = null);
            super.new(name, parent);
            has_checks = 1;
            has_coverage = 1;
            algn_data_width = 8;
            rx_exp_response_threshold = 10;
            tx_exp_item_threshold = 10;
            exp_irq_threshold = 10;
        endfunction

        virtual function void start_of_simulation_phase(uvm_phase phase);
            if(vif == null) begin
                `uvm_fatal("ISSUE", "The Aligner virtual interface has not been set at \"Start of Simulatiom Phase\"")
            end
        endfunction

        // Getter for has_checks control field
        virtual function bit get_has_checks();
            return has_checks;
        endfunction

        // Setter for has_checks control field
        virtual function void set_has_checks(bit value);
            has_checks = value;
        endfunction

        // Getter for has_coverage control field
        virtual function bit get_has_coverage();
            return has_coverage;
        endfunction

        // Setter for has_coverage control field
        virtual function void set_has_coverage(bit value);
            has_covareg = value;
        endfunction

        // Getter for algn_data_width control field
        virtual function int unsigned get_algn_data_width();
            return algn_data_width;
        endfunction

        // Setter for algn_data_width control field
        virtual function void set_algn_data_width(int unsigned value);
            //The minimum legal value for this field is 8.
            if(value < 8) begin
                `uvm_fatal("ISSUE", $sformatf("The minimum legal value for ALGN_DATA_WIDTH is 8 but user tried to set it to %0d", value))
            end
    
            //The value must be a power of 2
            if($countones(value) != 1) begin
                `uvm_fatal("ISSUE", $sformatf("The value for ALGN_DATA_WIDTH must be a power of 2 but user tried to set it to %0d", value))
            end
  
        endfunction

        virtual function algn_vif get_vif();
            return vif;
        endfunction

        virtual function void set_vif(algn_vif value);
            if( vif == null) begin
                vif = value;
            end
            else begin
                `uvm_fatal("ISSUE", "Trying to set vif more than once")
            end
        endfunction

        // Getter for rx_exp_response_threshold
        virtual function int unsigned get_rx_exp_response_threshold();
            return rx_exp_response_threshold;
        endfunction

        // Setter for r_exp_response_threshold
        virtual function void set_rx_exp_response_threshold(int unsigned value);
            rx_exp_response_threshold = value;
        endfunction

        // Getter for tx_exp_item_threshold
        virtual function int unsigned get_tx_exp_item_threshold();
            return tx_exp_item_threshold;
        endfunction

        // Setter for tx_exp_item_threshold
        virtual function void set_tx_exp_item_threshold(int unsigned value);
            tx_exp_item_threshold = value;
        endfunction

        // Getter for irq_threshold
        virtual function int unsigned get_exp_irq_threshold();
            return exp_irq_threshold;
        endfunction

        // Setter for tx_exp_item_threshold
        virtual function void set_exp_irq_threshold(int unsigned value);
            exp_irq_threshold = value;
        endfunction

    endclass

`endif 