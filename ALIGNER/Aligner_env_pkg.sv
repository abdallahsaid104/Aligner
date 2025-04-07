///////////////////////////////////////////////////////////////////////////////
// File:        Aligner_env_pkg.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Environment Package
///////////////////////////////////////////////////////////////////////////////
`ifndef ALIGNER_ENV_PKG_SV
    `define ALIGNER_ENV_PKG_SV

    `include"uvm_macros.svh"
    `include"apb_agent_pkg.sv"
    `include "md_pkg.sv"
    

    package Aligner_env_pkg;
        import uvm_pkg::*;
        import apb_agent_pkg::*;

        `include "aligner_env.sv"
        
    endpackage

`endif

