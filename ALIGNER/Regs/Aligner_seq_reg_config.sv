`ifndef ALIGNER_SEQ_REG_CONFIG_SV
    `define ALIGNER_SEQ_REG_CONFIG_SV

    class Aligner_seq_reg_config extends uvm_reg_seq;

        Aligner_reg_block reg_block;

        `uvm_object_utils(Aligner_seq_reg_config)
        function  new(string name = "Aligner_seq_reg_config")
            super.new(name);
        endfunction

        virtual task body()
            uvm_status_e status;
            uvm_reg_data_t data;

            void'(reg_block.CTRL.randomize());
      
            reg_block.CTRL.update(status);
      
            reg_block.CTRL.read(status, data);
            
        endtask

    endclass


`endif