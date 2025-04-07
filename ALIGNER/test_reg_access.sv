///////////////////////////////////////////////////////////////////////////////
// File:        test_reg_access.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Register access test (Target the APB access to the registers).
///////////////////////////////////////////////////////////////////////////////
`ifndef TEST_REG_ACCESS_SV
    `define TEST_REG_ACCESS_SV

    class test_reg_access extends test_base;

        //Number of register accesses
        protected int unsigned num_reg_accesses;

        //Number of unmapped accesses
        protected int unsigned num_unmapped_accesses;

        // Register the base test class with the factory
        uvm_copmonent_utils(test_reg_access);

        function new (string name = "test_reg_access", uvm_component parent = null);
            super.new(name,parent);
            num_reg_accesses      = 100;
            num_unmapped_accesses = 100;
        endfunction

        virtual task run_phase(uvm_phase phase);
            super.run_phase(phase);
            `uvm_info("REG_ACCESS_TEST", "Starting register access test", NONE);
            phase.raise_objection(this);
            #(100ns);
            fork
                begin
                    Aligner_virtual_sequence_reg_random seq = Aligner_virtual_sequence_reg_random::type_id::create("seq");
                    void'(seq.randomize() with {
                        num_accesses == num_reg_accesses;
                    });
                    seq.start(env.virtual_sequencer);
                end

                begin
                    Aligner_virtual_sequence_reg_unmapped seq = Aligner_virtual_sequence_reg_unmapped::type_id::create("seq");
                    void'(seq.randomize() with {
                        num_accesses == num_unmapped_accesses;
                    });
                    seq.start(env.virtual_sequencer); 
                end 
            join
            #(100ns);
            phase.drop_objection(this);
        endtask
    endclass
`endif
     