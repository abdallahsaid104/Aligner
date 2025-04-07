`ifndef ALIGNER_VIRTUAL_SEQUENCER_SV
    `define ALIGNER_VIRTUAL_SEQUENCER_SV

    class Aligner_virtual_sequencer extends uvm_sequencer;

        uvm_sequencer_base apb_sequencer;

        md_sequencer_base_master md_rx_sequencer;

        md_sequencer_base_slave md_tx_sequencer;

        Aligner_model model;

        `uvm_component_utils(Aligner_virtual_sequencer)
        function new(string name = "", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass


`endif