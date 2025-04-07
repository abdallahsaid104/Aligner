///////////////////////////////////////////////////////////////////////////////
// File:        apb_sequence_base.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Apb base sequence clase.
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_SEQUENCE_BASE_SV
    `define APB_SEQUENCE_BASE_SV

    class apb_sequence_base extends uvm_sequence #(.REQ(apb_item_drv));

        // Register the apb sequence base class with the factory
        uvm_opject_utils(apb_sequence_base);

        // Declare the p_sequencer handle
        `uvm_declare_p_sequencer(apb_sequencer)

        function new (string name = "apb_sequence_base");
            super.new(name);
        endfunction

    endclass
`endif 