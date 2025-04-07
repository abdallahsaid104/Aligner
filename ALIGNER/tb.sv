///////////////////////////////////////////////////////////////////////////////
// File:        tb.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Testbench module. It contains the instance of the DUT and the 
//              logic to start the UVM test and UVM phases.
///////////////////////////////////////////////////////////////////////////////
`include"Aligner_test_pkg.sv"
module tb();
    import uvm_pkg::*;
    import Aligner_test_pkg::*;

    localparam DATA_WIDTH = 32 ;
    reg clk;

    // Clock generator
    initial begin
        clk = 0;
        forever begin 
            clk = #5ns ~clk;
        end
    end

    // Instance of APB interface
    apb_if apb_if(.pclk(clk));

    // Instance of the MD_RX  interface
    md_if#(DATA_WIDTH) md_rx_if(.clk(clk));

    // Instance of the MD_TX  interface
    md_if#(DATA_WIDTH) md_tx_if(.clk(clk));

    // Instance off Aligner interface
    algn_if algn_if(.clk(clk));


    // Reset generator
    initial begin
        apb_if.preset_n = 1;
        #2ns;
        apb_if.preset_n = 0;
        #25ns;
        apb_if.preset_n = 1;
    end
    assign md_rx_if.reset_n = apb_if.preset_n;
    assign md_tx_if.reset_n = apb_if.preset_n;
    assign algn_if.reset_n = apb_if.preset_n;
    

    // DUT instance
    cfc_aligner#(.ALGN_DATA_WIDTH(`TEST_DATA_WIDTH)) dut(
        .clk(clk),
        .reset_n(apb_if.preset_n),
        .psel(apb_if.psel),
        .penable(apb_if.penable),
        .pwrite(apb_if.pwrite),
        .paddr(apb_if.paddr),
        .pwdata(apb_if.pwdata),
        .pready(apb_if.pready),
        .prdata(ap_if.prdata),
        .pslverr(apb_if.pslverr),

        .md_rx_valid(md_rx_if.valid),
        .md_rx_offset(md_rx_if.offset),
        .md_rx_data(md_rx_if.data),
        .md_rx_size(md_rx_if.size),
        .md_rx_ready(md_rx_if.ready),
        .md_rx_err(md_rx_if.err),

        .md_tx_valid(md_tx_if.valid),
        .md_tx_offset(md_tx_if.offset),
        .md_tx_data(md_tx_if.data),
        .md_tx_size(md_tx_if.size),
        .md_tx_ready(md_tx_if.ready),
        .md_tx_err(md_tx_if.err),

        .irq(algn_if.irq)
    );

    assign algn_if.rx_fifo_push = dut.core.rx_fifo.push_valid & dut.core.rx_fifo.push_ready;
    assign algn_if.rx_fifo_pop = dut.core.rx_fifo.pop_valid & dut.core.rx_fifo.pop_ready;
    assign algn_if.tx_fifo_push = dut.core.tx_fifo.push_valid & dut.core.tx_fifo.push_ready;
    assign algn_if.tx_fifo_pop = dut.core.tx_fifo.pop_valid & dut.core.tx_fifo.pop_ready;


    initial begin 
        $dumpfile("tb.vcd");
        $dumpvars;
        uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.apb_agent", "vif", apb_if);
        uvm_config_db#(virtual md_if#(DATA_WIDTH))::set(null, "uvm_test_top.env.md_rx_agent", "vif", md_rx_if);
        uvm_config_db#(virtual md_if#(DATA_WIDTH))::set(null, "uvm_test_top.env.md_tx_agent", "vif", md_tx_if);
        uvm_config_db#(virtual algn_if)::set(null, "uvm_test_top.env", "vif", algn_if);

        // Start UVM test and phases
        run_test("");
    end
endmodule