///////////////////////////////////////////////////////////////////////////////
// File:        apb_sequence_simple.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Apb simple sequence clase.
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_SEQUENCE_SIMPLE_SV
    `define APB_SEQUENCE_SIMPLE_SV

    class apb_sequence_simple extends uvm_sequence_base;

        // Register the apb simple sequence class with the factory
        uvm_opject_utils(apb_sequence_simple);

        // Item to randomize
        rand apb_item_drv item;


        function new (string name = "apb_sequence_simple");
            super.new(name);
            item = apb_item_drv::type_id::create("item");
        endfunction

        virtual task body();
            start_item(item);
            finish_item(item);
        endtask

    endclass
`endif 