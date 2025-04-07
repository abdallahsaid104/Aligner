///////////////////////////////////////////////////////////////////////////////
// File:        apb_sequence_random.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Apb random sequence clase.
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_SEQUENCE_RANDOM_SV
    `define APB_SEQUENCE_RANDOM_SV

    class apb_sequence_random extends uvm_sequence_base;

        // Register the apb random sequence class with the factory
        uvm_opject_utils(apb_sequence_random);

        // Random number of iterations
        rand int unsigned num_items;

        constraint num_items_c { soft num_items inside {[1:10]};}

        function new (string name = "apb_sequence_random");
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