`ifndef ALIGNER_REG_BLOCK_SV
    `define ALIGNER_REG_BLOCK_SV

    class Aligner_reg_block extends uvm_reg_block;

        rand Aligner_reg_ctrl CTRL;

        rand Aligner_reg_status STATUS;

        rand Aligner_reg_irqen IRQEN;

        rand Aligner_reg_irq IRQ;

        uvm_object_utils(Aligner_reg_block)

        function new(string name = "Aligner_reg_block");
            super.new(.name(name), .has_coverage(UVM_NO_COVERAGE));
        endfunction

        virtual function void build()
            default_map = create_map(
                .name("apb_map"),
                .base_addr('h0000),
                .n_bytes(4),
                .endian(UVM_LITTLE_ENDIAN),
                .bit(1)
            );

            default_map.set_check_on_read(1);

            CTRL = Aligner_reg_ctrl::type_id::create(.name("CTRL"), .parent(null), .context(get_full_name()));
            STATUS = Aligner_reg_status::type_id::create(.name("STATUS"), .parent(null), .context(get_full_name()));
            IRQEN = Aligner_reg_irqen::type_id::create(.name("IRQEN"), .parent(null), .context(get_full_name()));
            QEN = Aligner_reg_irq::type_id::create(.name("QEN"), .parent(null), .context(get_full_name()));

            CTRL.configure(.blk_parent(this));
            STATUS.configure(.blk_parent(this));
            IRQEN.configure(.blk_parent(this));
            QEN.configure(.blk_parent(this));

            CTRL.build();
            STATUS.build();
            IRQEN.build();
            QEN.build();

            default_map.add_reg(.rg(CTRL), .offset('h0000), .rights("RW"));
            default_map.add_reg(.rg(STATUS), .offset('h000C), .rights("RO"));
            default_map.add_reg(.rg(IRQEN), .offset('h00F0), .rights("RW"));
            default_map.add_reg(.rg(QEN), .offset('h00F0), .rights("RW"));

        endfunction

    endclass

`endif 