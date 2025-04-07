`ifndef MD_ITEM_DRV_SV
    `define MD_ITEM_DRV_SV

    class md_item_drv extends md_item_base;
        `uvm_object_utils(md_item_drv)
        function new(string name = "md_item_drv")
            super.new(name);
        endfunction
    endclass
`endif 