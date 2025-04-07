`ifdef MD_SEQUENCER_BASE_SLAVE_SV
    `define MD_SEQUENCER_BASE_SLAVE_SV

    class md_sequencer_base_slave extends md_sequencer_base#(.ITEM_DRV(md_item_drv_slave));
        
        `uvm_component_utils(md_sequencer_base_slave)

        uvm_analysis_imp#(md_item_mon, md_sequencer_base_slave) port_from_md_mon;

        uvm_tlm_fifo#(md_item_mon) pending_items;

        function new(string name = "md_sequencer_base_slave", uvm_component paret = null);
            super.new(name);

            port_from_md_mon = new("port_from_md_mon", this);

            pending_items = new("pending_items", this, 1)
        endfunction

        
        virtual function void write(md_item_mon item);
            if(item.is_active()) begin
                if(pending_items.is_full()) begin
                    `uvm_fatal("ISSUE",$sformatf("FIFO %0s is full (size:%0d)",pending_items.get_full_name(),pending_items.size()))
                end
                if(pending_items.try_put(item) == 0) begin
                    `uvm_fatal("ISSUE", $sformatf("Failed to push a new item in the FIFO %0s ", pending_items.get_full_name()))
                end
            end
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            super.handle_reset(phase);

            pending_items.flush();
        endfunction

    endclass

`endif