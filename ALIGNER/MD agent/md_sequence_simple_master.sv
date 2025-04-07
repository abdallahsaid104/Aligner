`ifndef MD_SEQUENCE_SIMPLE_MASTER_SV
    `define MD_SEQUENCE_SIMPLE_MASTER_SV

    class md_sequence_simple_master extends md_sequence_base_master;
        `uvm_object_utils(md_sequence_simple_master)

        rand md_item_drv_master item;

        //Bus data_width - used for simulators not supporting functions in constraints
        local int unsigned data_width;

        constraint item_hard {
            item.data.size() > 0;
            item.data.size() <= data_width/8;

            item.offset < data_width/8;

            item.data.size() + item.offset <= data_width/8
        }

        function new(string name = "md_sequence_simple_sequence");
            super.new(name);
            item = md_item_drv_master::type_id::create("item");
            item.data_default.constraint_mode(0);
            item.offset_default.constraint_mode(0);
        endfunction

        virtual function void pre_randomize();
            data_width = p_sequencer.get_data_width();
        endfunction

        virtual task body ();
            `uvm_send(item);
        endtask

    endclass

`endif