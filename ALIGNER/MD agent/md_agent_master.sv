`ifndef MD_AGENT_MASTER_SV
    `define MD_AGENT_MASTER_SV

    class md_agent_master#(int unsigned DATA_WIDTH = 32) extends md_agent#(DATA_WIDTH,md_item_drv_master);

        `uvm_component_param_utils(md_agent_master#(DATA_WIDTH))

        function new(string name = "md_agent_master", uvm_component parent = null);
            super.new(name, parent);
            md_agent_config#(DATA_WIDTH)::type_id::set_inst_override(md_agent_config_master#(DATA_WIDTH)::get_type(),"md_config",this);
            md_sequencer_base#(md_item_drv_master)::type_id::set_inst_override(md_sequencer_master#(DATA_WIDTH)::get_type(),"sequencer",this);
            md_driver#(md_item_drv_master)::type_id::set_inst_override(md_driver_master#(DATA_WIDTH)::get_type(),"driver",this);
        endfunction
    endclass

`endif