///////////////////////////////////////////////////////////////////////////////
// File:        md_pkg.sv
// Author:      Abdallah Said
// Date:        2025/03/14
// Description: MD Protocol Package
///////////////////////////////////////////////////////////////////////////////
`ifndef MD_PKG_SV
    `define MD_PKG_SV

    `include"uvm_macros.svh"
    `include"md_if.sv"
    
    package md_pkg;
        import uvm_pkg::*; 
        `include "md_reset_handler.sv"
        `include "md_agent_config.sv"
        `include "md_agent_config_master.sv"
        `include "md_agent_config_slave.sv"
        
        `include "md_agent.sv"
        `include "md_agent_master.sv"
        `include "md_agent_slave.sv"
        

    endpackage

`endif

