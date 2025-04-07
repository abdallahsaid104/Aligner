`ifndef MD_SEQUENCER_BASE_MASTER_SV
    `define MD_SEQUENCER_BASE_MASTER_SV

    class md_sequencer_base_master extends md_sequencer_base#(.ITEM_DRV(md_item_drv_master));
        `uvm_component_param_utils(md_sequencer_base_master)

        function new(string name = "md_sequencer_base_master", uvm_component parent = null);
            super.new(name, parent);
        endfunction

    endclass
`endif 