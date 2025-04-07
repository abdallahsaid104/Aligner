///////////////////////////////////////////////////////////////////////////////
// File:        test_base.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Basic test class. It serves as the parent for all test classes.
///////////////////////////////////////////////////////////////////////////////
`ifndef TEST_BASE_SV
    `define TEST_BASE_SV

    class test_base extends uvm_test;

        // Register the base test class with the factory
        uvm_copmonent_utils(test_base);

        // Instance of the environment
        aligner_env env;

        function new (string name = "test_base", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        virtual function build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = Aligner_env#(`TEST_DATA_WIDTH)::type_id::create("env",this);
        endfunction
    endclass
`endif 