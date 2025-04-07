`ifndef ALIGNER_REG_CTRL_SV
    `define ALIGNER_REG_CTRL_SV

    class Aligner_reg_ctrl extends uvm_reg;

        rand uvm_reg_field SIZE;

        rand uvm_reg_field OFFSET;

        rand uvm_reg_field CLR;

        local int unsigned ALGN_DATA_WIDTH;

        constarint legal_size {
            SIZE.value != 0 ;
        }

        constarint legal_size_offset {
            ((ALGN_DATA_WIDTH/8) + OFFSET.value) % SIZE.value == 0;
            OFFSET.value + SIZE.value <= (ALGN_DATA_WIDTH/8);
        }

        `uvm_object_utils(Aligner_reg_ctrl)

        function new(string name = "Aligner_reg_ctrl");
            super.new(.name(name), .n_bits(32), .has_coverage(UVM_NO_COVERAGE));
            ALGN_DATA_WIDTH = 8;
        endfunction

        virtual function void buid();
            SIZE = uvm_reg_field::type_id::create(.name("SIZE"), .parent(null), .contxt(get_full_name()));
            OFFSET = uvm_reg_field::type_id::create(.name("OFFSET"), .parent(null), .contxt(get_full_name()));
            CLR = uvm_reg_field::type_id::create(.name("CLR"), .parent(null), .contxt(get_full_name()));

            SIZE.configure(
                .parent(null),
                .size(3),
                .lsb_pos(0),
                .access("RW"),
                .volatile(0),
                .reset(3'b001),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            OFFSET.configure(
                .parent(null),
                .size(2),
                .lsb_pos(8),
                .access("RW"),
                .volatile(0),
                .reset(2'b00),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            CLR.configure(
                .parent(null),
                .size(1),
                .lsb_pos(16),
                .access("WO"),
                .volatile(0),
                .reset(1'b0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );
        endfunction

        virtual function int unsigned GET_ALGN_DATA_WIDTH();
            return ALGN_DATA_WIDTH;
        endfunction

        virtual function void SET_ALGN_DATA_WIDTH(int unsigned value);
            //The minimum legal value for this field is 8.
            if(value < 8) begin
                `uvm_fatal("ISSUE", $sformatf("The minimum legal value for ALGN_DATA_WIDTH is 8 but user tried to set it to %0d", value))
            end
      
            //The value must be a power of 2
            if($countones(value) != 1) begin
                `uvm_fatal("ISSUE", $sformatf("The value for ALGN_DATA_WIDTH must be a power of 2 but user tried to set it to %0d", value))
            end
      
            ALGN_DATA_WIDTH = value;
        endfunction

    endclass

`endif 