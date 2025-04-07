`ifndef MD_SEQUENCE_SIMPLE_SLAVE_SV
    `define MD_SEQUENCE_SIMPLE_SLAVE_SV

    class md_sequence_simple_slave extends md_sequence_base_slave#(md_item_drv_slave);
        `uvm_object_utils(md_sequence_simple_slave)

        rand md_item_drv_slave item;

        function new(string name = "md_sequence_simple_slave");
            super.new(name);
            item = md_item_drv_slave::type_id::create("item");
        endfunction

        virtual task body ();
            `uvm_send(item);
        endtask

    endclass

`endif