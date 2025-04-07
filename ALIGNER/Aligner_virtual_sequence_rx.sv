`ifndef ALIGNER_VIRTUAL_SEQUENCE_RX_SV
    `define ALIGNER_VIRTUAL_SEQUENCE_RX_SV

    class Aligner_virtual_sequence_rx extends Aligner_virtual_sequence_base;

        rand md_sequence_simple_master seq;
    
        `uvm_object_utils(Aligner_virtual_sequence_rx)

    
        function new(string name = "Aligner_virtual_sequence_rx");
            super.new(name);
            seq = md_sequence_simple_master::type_id::create("seq");
        endfunction

        virtual task body();
            seq.start(p_sequencer.md_rx_sequencer);;
        endtask

        function void pre_randomize();
            super.pre_randomize();
            seq.set_sequencer(p_sequencer.md_rx_sequencer);
        endfunction
    
    endclass 



`endif