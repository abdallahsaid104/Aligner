`ifndef ALIGNER_COVERAGE_SV
    `define ALIGNER_COVERAGE_SV
    `uvm_analysis_imp_decl(_in_split_info)

    class Aligner_coverage extends uvm_ccomponent implements uvm_ext_reset_handler;

        uvvm_analysis_imp_in_split_info#(split_info, Aligner_coverage) port_in_split_info;

        `uvm_component_utils(Aligner_coverage)

        covergroup cover_split with function sample(split_info info);
            option.per_instance = 1;

            ctrl_offset : coverpoint info.ctrl_offset {
                option.comment = "Value of CTRL.OFFSET";
                bins values[]  = {[0:3]};
            }
            ctrl_size : coverpoint info.ctrl_size {
                option.comment = "Value of CTRL.SIZE";
                bins values[]  = {[1:4]};
            }
            md_offset: coverpoint info.md_offset {
                option.comment = "Value of MD.OFFSET";
                bins values[]  = {[0:3]};
            }
            md_size: coverpoint info.md_size {
                option.comment = "Value of MD.SIZE";
                bins values[]  = {[1:4]};
            }
            num_bytes_needed: coverpoint info.num_bytes_needed {
                option.comment = "Value of NUM_BYTES_NEEDED";
                bins values[]  = {[1:3]};
            }
            all: cross ctrl_offset, ctrl_size, md_offset, md_size, num_bytes_needed;{
                ignore_bins ignore_ctrl = (binsof(ctrl_offset) intersect {0} && binsof(ctrl_size) intersect {3}) ||
                                          (binsof(ctrl_offset) intersect {1} && binsof(ctrl_size) intersect {2, 3, 4}) ||
                                          (binsof(ctrl_offset) intersect {2} && binsof(ctrl_size) intersect {3, 4}) ||
                                          (binsof(ctrl_offset) intersect {3} && binsof(ctrl_size) intersect {2, 3, 4});
            }


        endgroup
        
        function new(string name = "Aligner_coverage", uvm_component parent = null);
            super.new(name, paret);
            port_in_split_info = new("port_in_split_info", this);
            cover_split = new();
            cover_split.set_inst_name($sformatf("%0s_%0s", get_full_name(), "cover_split"));
        endfunction

        virtual function void write_in_split_info(split_info info);
            cover_split.sample(info);

        endfunction

        virtual function void handle_reset(uvm_phase phase);

        endfunction

        virtual function string cov2str();
            string result = {
                $sformatf("\n   cover_split:            %03.2f%%", cover_split.get_inst_coverage()),
                $sformatf("\n      ctrl_offset:         %03.2f%%", cover_split.ctrl_offset.get_inst_coverage()),
                $sformatf("\n      ctrl_size:           %03.2f%%", cover_split.ctrl_size.get_inst_coverage()),
                $sformatf("\n      md_offset:           %03.2f%%", cover_split.md_offset.get_inst_coverage()),
                $sformatf("\n      md_size:             %03.2f%%", cover_split.md_size.get_inst_coverage()),
                $sformatf("\n      num_bytes_needed:    %03.2f%%", cover_split.num_bytes_needed.get_inst_coverage()),
                $sformatf("\n      all:                 %03.2f%%", cover_split.all.get_inst_coverage())
            };

            return result;
        endfunction

        virtual function void report_phase(uvm_phase phase);
            super.report_phase(phase);

            `uvm_info("DEBUG", $sformatf("Coverage: %0s", cov2str()), UVM_NONE)
        endfunction

    endclass

`endif