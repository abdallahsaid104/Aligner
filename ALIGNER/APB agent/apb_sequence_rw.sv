///////////////////////////////////////////////////////////////////////////////
// File:        apb_sequence_rw.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Apb read-write sequence clase.
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_SEQUENCE_RW_SV
    `define APB_SEQUENCE_RW_SV

    class apb_sequence_rw extends uvm_sequence_base;

        // Register the apb read-write sequence class with the factory
        uvm_opject_utils(apb_sequence_rw);

        // Address
        rand APB_ADDR addr;

        // Data
        rand APB_DATA data;


        function new (string name = "apb_sequence_rw");
            super.new(name);
        endfunction

        virtual task body();
            apb_item_drv item;
            `uvm_do_with(item, {
                direction == APB_READ;
                addr == local::adder;
            });

            `uvm_do_with(item, {
                direction == APB_WRITE;
                addr == local::adder;
                data == local::data;
            });
        endtask

    endclass
`endif 