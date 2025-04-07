`ifndef MD_DRIVER_SV
    `define MD_DRIVER_SV
    
    class md_driver#(int unsigned DATA_WIDTH = 32 , type ITEM_DRV = md_item_drv) extends uvm_ext_driver#(.VIRTUAL_IF(virtual md_id#(DATA_WIDTH)), .ITEM_DRV(ITEM_DRV))

        md_agent_config#(DATA_WIDTH) agent_config;
        
        `uvm_ccomponent_param_utils(md_driver#(DATA_WIDTH,ITEM_DRV))

        function new(string name = "md_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        virtual function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);
            if($cast(agent_config, super.agent_config) == 0) begin
                `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Could not cast %0s to %0s", 
                   super.agent_config.get_type_name(), apb_agent_config::type_id::type_name))
              end
        endfunction

    endclass

`endif 