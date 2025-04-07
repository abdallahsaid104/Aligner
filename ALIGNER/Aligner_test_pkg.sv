///////////////////////////////////////////////////////////////////////////////
// File:        Aligner_test_pkg.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Test Package
///////////////////////////////////////////////////////////////////////////////
`ifndef ALIGNER_TEST_PKG_SV
    `define ALIGNER_TEST_PKG_SV

    `include"uvm_macros.svh"
    `include"Aligner_env_pkg.sv"
    

    package Aligner_test_pkg;
        import uvm_pkg::*;
        import Aligner_env_pkg::*;
        import apb_agent_pkg::*;

        `include "test_defines.sv"
        `include "test_base.sv"
        `include "test_reg_access.sv"
        
    endpackage

`endif
///////////////////////////////////////////////////////////////////////////////
