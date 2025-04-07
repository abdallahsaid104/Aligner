`ifndef MD_SEQUENCE_SLAVE_RESPONSE_SV
    `define MD_SEQUENCE_SLAVE_RESPONSE_SV

    class md_sequence_slave_response extends md_sequence_base_slave;
        `uvm_object_utils(md_sequence_slave_response)

        function  new(string name = "md_sequence_slave_response");
            super.new(name);
        endfunction

        virtual task body()
            md_item_mon item_mon;
            p_sequencer.pending_items.get(item_mon);
            md_sequence_base_slave seq;
            `uvm_do(seq)
        endtask
    endclass
`endif