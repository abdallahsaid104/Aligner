///////////////////////////////////////////////////////////////////////////////
// File:        md_if.sv
// Author:      Abdallah Said
// Date:        2025/03/14
// Description: MD interface module. It contains the MD interface signals.
///////////////////////////////////////////////////////////////////////////////
`ifndef MD_IF_SV
    `define MD_IF_SV
     
    interface apb_if#(int unsigned DATA_WIDTH = 32)(input clk);

        // Width of the offset signal = max(1,log2(DATA_WIDTH/8))
        localparam OFFSET_WIDTH = $clog2(DATA_WIDTH/8) < 1 ? 1 : $clog2(DATA_WIDTH/8) ;

        // Width of the size signal = log2(DATA_WIDTH/8) + 1
        localparam SIZE_WIDTH = $clog2(DATA_WIDTH/8) + 1;

        logic reset_n;
        logic valid;
        logic [OFFSET_WIDTH-1 : 0 ] offset;
        logic [DATA_WIDTH-1 : 0 ] data ;
        logic [SIZE_WIDTH-1 : 0 ] size;
        logic ready;
        logic err;

        // Switch to enable checks
        bit has_checks;

        initial begin
            has_checks = 1;     // Default value to have checks.
        end

        /*      ----------------> MD protocol checks  <--------------------
                1- DATA_WIDTH must be of power 2.
                2- DATA_WIDTH minimum legal value must be 8.
                3- Once valid becomes high, it must stay high until ready becomes high.
                4- data is valid while valid is high 
                5- data must remain constant until ready becomes high.
                6- offset is valid while valid is high 
                7- offset must remain constant until ready becomes high.
                8- Not all combinations of (offset, size) are legal 
                   ( the legal combinations: ((ALGN_DATA_WIDTH / 8) + offset) % size == 0) 
                9- size  0 is illegal – must never be used.
                10- size is valid while valid is high.
                11- and must remain constant until ready becomes high.
                12- err is valid only when both valid and ready are high.
                13- 
        */
     
    endinterface 

`endif 