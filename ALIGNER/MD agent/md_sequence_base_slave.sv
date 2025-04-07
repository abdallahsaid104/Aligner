`ifndef MD_SEQUENCE_BASE_SLAVE_SV
    `define MD_SEQUENCE_BASE_SLAVE_SV

    class md_sequence_base_slave extends md_sequence_base#(.ITEM_DRV(md_item_drv_slave));
    
        `uvm_declare_p_sequencer(md_sequence_base_slave)

        `uvm_object_utils(md_sequence_base_slave)

        function new(string name = "md_sequence_base_slave");
            super.new(name);
        endfunction
    endclass

`endif