`ifndef ALIGNER_REGS_PKG_SV
    `define ALIGNER_REGS_PKG_SV

    package Aligner_regs_pkg;

        import uvm_pkg::*;

        `include "Aligner_reg_ctrl.sv"
        `include "Aligner_reg_status.sv"
        `include "Aligner_reg_irqen.sv"
        `include "Aligner_reg_irq.sv"
    endpackage


`endif 