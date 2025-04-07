`ifndef MD_DRIVER_SLAVE_SV
    `define MD_DRIVER_SLAVE_SV

    class md_driver_slave#(int unsigend DATA_WIDTH = 32) extends md_driver(.DATA_WIDTH(DATA_WIDTH), .ITEM_DRV(md_item_drv_slave));

        md_agent_config_slave#(DATA_WIDTH) agent_config;

        typedef virtual md_if#(DATA_WIDTH) md_vif;

        `uvm_component_param_utils(md_driver_slave#(DATA_WIDTH))

        function new(string name = "md_driver_slave", uvm_component paret = null);
            super.new(name,parent);
        endfunction

        virtual function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);
              
            if(super.agent_config == null) begin
                `uvm_fatal("ISSUE", $sformatf("At this point the pointer to agent_config from %0s should not be null", get_full_name()))
            end
              
            if($cast(agent_config, super.agent_config) == 0) begin
                `uvm_fatal("ISSUE", $sformatf("Could not cast %0s to %0s", super.agent_config.get_full_name(), cfs_md_agent_config_slave#(DATA_WIDTH)::type_id::type_name))
            end
              
         endfunction

        protected virtual task drive_transaction(md_item_drv_slave item);
            md_vif vif = agent_config.get_vif();
            `uvm_info("MD_DRIVER_SLAVE",$sformatf("Drivig \"%0s\" : %0s",item.get_full_name(), item.conv2str()),UVM_NONE)

            if(vif.valid !== 1) begin
                `uvm_error("ISSUE", $sformatf("Trying to drive a slave item when there is no item started by the master - item:%0s",
                                            item.conv2str()))
            end
            vif.ready <= 0;

            for(int i = 0; i < item.length; i++) begin
                @(posedge vif.clk);
            end

            vif.ready <= 1;
            vif.err <= bit'(item.response);

            @(posedge vif.clk);

            vif.ready <= item.ready_at_end;
            vif.err <= 0 ;
        endtask 

        virtual function void handle_reset(uvm_phase phase)
            md_vif  vif = agent_config.get_vif();
            super.handle_reset(phase);

            vif.ready <= agent_config.get_ready_at_reset();
            vif.err <= 0;
        endfunction

    endclass

`endif 