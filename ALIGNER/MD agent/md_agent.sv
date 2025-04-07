`ifndef MD_AGENT_SV
    `define MD_AGENT_SV

    class md_agent#(int unsigned DATA_WIDTH = 32, type ITEM_DRV = md_item_drv) extends uvm_ext_agent#(.VIRTUAL_IF(virtual md_if#(DATA_WIDTH)),.ITEM_DRV(ITEM_DRV),.ITEM_MON(md_item_mon));

        typedef virtual md_if#(DATA_WIDTH) md_vif;
        
        // Register the md agent class with the factory
        uvm_copmonent_utils(md_agent#(DATA_WIDTH, ITEM_DRV));
 
        function new (string name = "md_agent", uvm_component parent = null);
            super.new(name,parent);
            uvm_ext_agent_config#(.VIRTUAL_IF(md_vif))::type_id::set_inst_override(md_agent_config::get_type(),"agent_config",this);
            uvm_ext_driver#(.VIRTUAL_IF(md_vif),.ITEM_DRV(ITEM_DRV))::type_id::set_inst_override(md_driver::get_type(),"driver",this);
            uvm_ext_monitor#(.VIRTUAL_IF(md_vif),.ITEM_MON(md_item_mon))::type_id::set_inst_override(md_monitor::get_type(),"monitor",this);
            uvm_ext_coverage#(.VIRTUAL_IF(md_vif), .ITEM_MON(md_item_mon))::type_id::set_inst_override(md_coverage::get_type(), "coverage", this);
            uvm_ext_sequencer#(.VIRTUAL_IF(md_vif),.ITEM_DRV(ITEM_DRV))::type_id::set_inst_override(md_sequencer_base::get_type(),"sequencer",this);        
        endfunction

    endclass
`endif 