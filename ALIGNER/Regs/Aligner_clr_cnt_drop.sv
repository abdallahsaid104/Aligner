`ifndef ALIGNER_CLR_CNT_DROP_SV
    `define ALIGNER_CLR_CNT_DROP_SV

    class Aligner_clr_cnt_drop extends uvm_reg_cbs;

        uvm_reg_field cnt_drop;

        `uvm_object_utils(Aligner_clr_cnt_drop)

        function new(string name = "Aligner_clr_cnt_drop");
            super.new(name);
        endfunction
        virtual function voidd post_predict(
            input uvm_reg_field fld,
            input uvm_reg_data_t previous,
            input uvm_reg_data_t value,
            input uvm_predict_e kind,
            input uvm_path_e path,
            input uvm_reg_map map);
            
            if(kind == UVM_PREDICT_WRITE) begin
                if(value == 1) begin
                    void'(cnt_drop.predict(0));

                    value = 0;
                    `uvm_info("DEBUG", $sformatf("Clearing %0s",cnt_drop.get_full_name()),UVM_NONE)
                end
            end 

        endfunction
    endclass

`endif