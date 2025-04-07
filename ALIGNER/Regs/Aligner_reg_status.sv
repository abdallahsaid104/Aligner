`ifndef ALIGNER_REG_STATUS_SV
    `define ALIGNER_REG_STATUS_SV

    class Aligner_reg_status extends uvm_reg;

        rand uvm_reg_field CNT_DROP;

        rand uvm_reg_field RX_LVL;

        rand uvm_reg_field TX_LVL;

        `uvm_object_utils(Aligner_reg_status)

        function new(string name = "Aligner_reg_status");
            super.new(.name(name), .n_bits(32), .has_coverage(UVM_NO_COVERAGE));
        endfunction

        virtual function void buid();
            CNT_DROP = uvm_reg_field::type_id::create(.name("CNT_DROP"), .parent(null), .contxt(get_full_name()));
            RX_LVL = uvm_reg_field::type_id::create(.name("RX_LVL"), .parent(null), .contxt(get_full_name()));
            TX_LVL = uvm_reg_field::type_id::create(.name("TX_LVL"), .parent(null), .contxt(get_full_name()));

            CNT_DROP.configure(
                .parent(null),
                .size(8),
                .lsb_pos(0),
                .access("RO"),
                .volatile(0),
                .reset(8'b00000000),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            RX_LVL.configure(
                .parent(null),
                .size(4),
                .lsb_pos(8),
                .access("RO"),
                .volatile(0),
                .reset(4'b0000),
                .has_reset(41),
                .is_rand(1),
                .individually_accessible(0)
            );

            TX_LVL.configure(
                .parent(null),
                .size(1),
                .lsb_pos(16),
                .access("RO"),
                .volatile(0),
                .reset(4'b0000),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );
        endfunction

    endclass

`endif 