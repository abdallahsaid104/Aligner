`ifndef MD_COVERAGE_SV
    `define MD_COVERAGE_SV

    class md_coverage#(int unsigned DATA_WIDTH = 32) extends uvm_ext_coverage#(.VIRTUAL_IF(virtual md_if#(DATA_WIDTH)), .ITEM_MON(md_item_mon));
        
        typedef virtual md_if#(DATA_WIDTH) md_vif;

        md_agent_config#(DATA_WIDTH) agent_config;

        //Wrapper over the coverage group covering the indices in the data signal at which the bit of the data was 0        
        uvm_ext_cover_index_wrapper#(DATA_WIDTH) wrap_cover_data_0;

        //Wrapper over the coverage group covering the indices in the data signal at which the bit of the data was 1
        uvm_ext_cover_index_wrapper#(DATA_WIDTH) wrap_cover_data_1;

        covergroup cover_item with function sample(md_item_mon item);
            option.per_instance = 1;

            offset: coverpoint item.offset{
                option.comment = "offset of the MD access";
                bins values [] = {[0: (DATA_WIDTH/8)-1]};
            }
            size: coverpoint item.data.size(){
                option.comment = "size of the MD transaction";
                bins values [] = {[1: (DATA_WIDTH/8)]};
            }
            response: coverpoint item.response{
                option.comment = "response of the MD access";
            }
            length: coverpoint item.lenght{
                option.comment = "length of the MD transaction";
                bins length_eq_1 = [1];
                bins length_le_10 [9] = [2:10];
                bins length_gt_10 = [11:$];

                illegal_bins length_eq_0 = [0];
            }
            prev_item_delay: coverpoint item.prev_item_delay {
                option.comment = "delay in clock cycles between 2 consecutive MD transactions";
                bins back2back = [0];
                bins delay_le_5[5] = {[1:5]};
                bins delay_gt_5 = {[6:$]};  
            }
            offset_cross_size: offset cross size {
                ignore_bins ignore_offset_blus_size_gt_data_width = offset_cross_size with ((offset + size) > (DATA_WIDTH/8));
            }

        endgroup

        covergroup cover_reset with function sample(bit valid);
            option.per_instance = 1;
      
            access_ongoing : coverpoint valid {
                option.comment = "An MD access was ongoing at reset";
            }
        endgroup
    
        `uvm_component_param_utils(md_coverage#(DATA_WIDTH))
        
        function new(strng name = "md_coverage", uvm_component parent =null);
            super.new(name, parent);
            cover_item = new();
            cover_item.set_inst_name($sformatf("%0s %0s", get_full_name(), "cover_item")); 

            cover_reset = new(); 
            cover_rest.set_inst_name($sformatf("%0s %0s", get_full_name(), "cover_reset"));
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            wrap_cover_data_0  = uvm_ext_cover_index_wrapper#(DATA_WIDTH)::type_id::create("wrap_cover_data_0", this);
            wrap_cover_data_1  = uvm_ext_cover_index_wrapper#(DATA_WIDTH)::type_id::create("wrap_cover_data_1", this);
        endfunction

        // Write function associated with the coverage_port
        virtual function void write_item(md_item_mon item);
            cover_item.sample(item);

            foreach (item.data[byte_index]) begin
                for(int bit_index = 0; bit_index < 8; bit_index++) begin
                    if(item.data[byte_index][bit_index]) begin
                        wrap_cover_data_1.sampel((item.offset * 8 ) + (byte_index) * 8 + bit_index);
                    end
                        wrap_cover_data_0.sampel((item.offset * 8 ) + (byte_index) * 8 + bit_index);
                end
            end
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            md_vif vif = agent_config.get_vif();

            cover_reset.sample(vif.valid);
        endfunction

        // Function to convert the coverage to string (As i run simulation on EDA playground)
        virtual function string cov2str();
            string result = {
                $sformatf("\n    cover_item:                %0.3.2f%%", cover_item.get_inst_coverage()),
                $sformatf("\n    offset:                    %0.3.2f%%", cover_item.offset.get_inst_coverage()),
                $sformatf("\n    size:                      %0.3.2f%%", cover_item.size.get_inst_coverage()),
                $sformatf("\n    response:                  %0.3.2f%%", cover_item.response.get_inst_coverage()),
                $sformatf("\n    length:                    %0.3.2f%%", cover_item.lenght.get_inst_coverage()),
                $sformatf("\n    prev_iten_delay:           %0.3.2f%%", cover_item.prev_item_delay.get_inst_coverage()),
                $sformatf("\n    offset_cross_size:         %0.3.2f%%", cover_item.offset_cross_size.get_inst_coverage()),
                $sformatf("\n                                    "),
                $sformatf("\n    cover_reset:               %0.3.2f%%", cover_reset.get_inst_coverage()),
                $sformatf("\n    access_ongoing:            %0.3.2f%%", cover_reset.access_ongoing.get_inst_coverage())
                super.cov2str();
            };

            return result;           
        endfunction

    endclass

`endif