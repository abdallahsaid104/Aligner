`ifndef ALIGNER_VIRTUAL_SEQUENCE_BASE_SV
    `define ALIGNER_VIRTUAL_SEQUENCE_BASE_SV

    class Aligner_virtual_sequence_base extends uvm_sequence;

        `uvm_declare_p_sequencer(Aligner_virtual_sequencer)

        `uvm_object_utils(Aligner_virtual_sequence_base)

        function new(string name = "Aligner_virtual_sequence_base");
            super.new(name);
        endfunction

    endclass
`endif