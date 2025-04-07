`ifndef TEST_RANDOM_SV
    `define TEST_RANDOM_SV

    class test_random extends test_base;

        protected int unsigned num_md_rx_transactions;

        `uvm_copmonent_utils(test_random)
        function new(string name = "test_random", uvm_component parent = null);
            super.new(name, parent);
            num_md_rx_transactions = 100;
        endfunction

        virtual task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this, "TEST_START");
            #(100ns);
            fork
                begin
                    md_sequence_slave_response_forever seq = md_sequence_slave_response_forever::type_id::create("seq");
                    seq.start(env.md_tx_agent.sequencer);
                end
            join_none
            repeat(2) begin
                begin
                    Aligner_virtual_sequence_reg_config seq = Aligner_virtual_sequence_reg_config::type_id::create("seq");
                    void'(seq.randomize());
                    seq.start(env.virtual_sequencer);
                end

                repeat(num_md_rx_transactions) begin
                    Aligner_virtual_sequence_rx seq = Aligner_virtual_sequence_rx::type_id::create("seq");
                    void'(seq.randomize());
                    seq.start(env.virtual_sequencer);
                end

                begin
                    algn_vif vif = env.env_config.get_vif();
                    repeat(100) begin
                        @(vif.clk);
                    end
                end

                begin
                    Aligner_virtual_sequence_reg_status seq = Aligner_virtual_sequence_reg_status::type_id::create("seq");
                    void'(seq.randomize());
                    seq.start(env.virtual_sequencer);
                end
            end

            #(500ns);
            `uvm_info("DEBUG", "The end of the test", UVM_NONE);

            phase.drop_objection(this, "TEST_DONE");
        endtask

    endclass

`endif