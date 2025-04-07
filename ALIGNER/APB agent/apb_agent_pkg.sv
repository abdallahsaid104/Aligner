///////////////////////////////////////////////////////////////////////////////
// File:        apb_agent_pkg.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: APB Agnet Package
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_AGENT_PKG_SV
    `define APB_AGENT_PKG_SV

    `include"uvm_macros.svh"
    `include"apb_if.sv"
    

    package apb_agent_pkg;
        import uvm_pkg::*;

        // APB Types
        `include "apb_types.sv"

        // APB Reset Handler
        `include "apb_reset_handler.sv"

        // APB Items
        `include "apb_item_base.sv"
        `include "apb_item_drv.sv"
        `include "apb_item_mon.sv"

        // APB Configuration
        `include "apb_agent_config.sv"

        // APB Sequencer
        `include "apb_sequencer.sv"
        
        // APB Monitor
        `include "apb_monitor.sv"

        // APB Driver
        `incclude "apb_driver.sv"

        // APB Agent
        `include "apb_agent.sv"

        // APB Sequences
        `include "apb_sequence_base.sv"
        `include "apb_sequence_simple.sv"
        `include "apb_sequence_rw.sv"
        `include "apb_sequence_random.sv"

        // APB Coverage
        `include "apb_coverage.sv"
  
    endpackage

`endif

