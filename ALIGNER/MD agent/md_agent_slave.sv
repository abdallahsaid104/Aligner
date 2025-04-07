`ifndef MD_AGENT_SLAVE_SV
    `define MD_AGENT_SLAVE_SV

    class md_agent_slave#(int unsigned DATA_WIDTH = 32) extends md_agent#(DATA_WIDTH, md_item_drv_slave);

        `uvm_component_param_utils(md_agent_slave#(DATA_WIDTH))

        function new(string name = "md_agent_slave", uvm_component parent = null);
            super.new(name, parent);
            md_agent_config#(DATA_WIDTH)::type_id::set_inst_override(md_agent_config_slave#(DATA_WIDTH)::get_type(),"md_config",this);
            md_driver#(DATA_WIDTH,md_item_drv_slave)::type_id::set_inst_override(md_driver_slave#(DATA_WIDTH)::get_type(),"driver",this);
            md_sequencer_base#(md_item_drv_slave)::type_id::set_inst_override(md_sequencer_base_slave#(DATA_WIDTH)::get_type(),"sequencer",this);
        endfunction
    endclass

`endif