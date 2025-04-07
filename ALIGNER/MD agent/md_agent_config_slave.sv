///////////////////////////////////////////////////////////////////////////////
// File:        md_agent_config_slave.sv
// Author:      Abdallah Said
// Date:        2025/03/15
// Description: configuration class for MD slave agent.
///////////////////////////////////////////////////////////////////////////////
`ifndef MD_AGENT_CONFIG_SLAVE_SV
    `define MD_AGENT_CONFIG_SLAVE_SV

    class md_agent_config_slave#(int unsigned DATA_WIDTH = 32) extends md_agent_config#(DATA_WIDTH);

        `uvm_ccomponent_param_utils(md_agent_config_slave)

        // Value of ready signal at reset
        local bit ready_at_reset;

        function new(string name = "md_agent_config_slave", uvm_component parent = null);
            super.new(name,parent);

            // Default value for ready_at_reset
            ready_at_reset = 1;
        endfunction

        // Getter of ready_at_reset
        virtual function bit get_ready_at_reset();
            return ready_at_reset
        endfunction

        // Setter for ready_at_reset
        virtual function void set_ready_at_reset(bit value);
            ready_at_reset = value;
        endfunction
    endclass

`endif 