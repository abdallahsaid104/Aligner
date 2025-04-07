///////////////////////////////////////////////////////////////////////////////
// File:        md_agent_config_master.sv
// Author:      Abdallah Said
// Date:        2025/03/15
// Description: configuration class for MD master agent.
///////////////////////////////////////////////////////////////////////////////
`ifndef MD_AGENT_CONFIG_MASTER_SV
    `define MD_AGENT_CONFIG_MASTER_SV

    class md_agent_config_master#(int unsigned DATA_WIDTH = 32) extends md_agent_config#(DATA_WIDTH);

        `uvm_ccomponent_param_utils(md_agent_config_master)

        function new(string name = "md_agent_config_master", uvm_component parent = null);
            super.new(name,parent);
        endfunction
    endclass

`endif 