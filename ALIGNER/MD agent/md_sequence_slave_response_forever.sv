`ifndef MD_SEQUENCE_SLAVE_RESPONSE_FOREVER_SV
    `define MD_SEQUENCE_SLAVE_RESPONSE_FOREVER_SV

    class md_sequence_slave_response_forever extends md_sequence_base_slave;
        `uvm_object_utils(md_sequence_slave_response_forever)

        function  new(string name = "md_sequence_slave_response_forever");
            super.new(name);
        endfunction

        virtual task body()
            forever begin
                md_sequence_slave_response seq = md_sequence_slave_response::type_id::create("seq");
                `uvm_do_on(seq, p_sequencer)
            end
        endtask
    endclass
`endif