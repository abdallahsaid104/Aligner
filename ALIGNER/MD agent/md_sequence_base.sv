`ifndef MD_SEQUENCE_BASE_SV
    `define MD_SEQUENCE_BASE_SV

    class md_sequence_base#(type  ITEM_DRV = md_item_drv) extends uvm_sequence#(.REQ(ITEM_DRV)) 

        `uvm_object_param_utils(md_sequence_base#(ITEM_DRV))

        `uvm_declare_p_sequencer(md_sequencer#(ITEM_DRV))

        function new(string name = "md_sequence_base")
            super.new(name);    
        endfunction
    endclass

`endif  