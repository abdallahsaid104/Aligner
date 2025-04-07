`ifndef APB_COVERAGE_SV
    `define APB_COVERAGE_SV

    class apb_coverage extends uvm_ext_coverage#(.VIRTUAL_IF(apb_vif), .ITEM_MON(apb_item_mon));

        // APB_agent_config handle
        apb_agent_config agent_config;

        //Wrapper over the coverage group covering the indices in the paddr signal at which the bit of the paddr was 0
        uvm_ext_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH) wrap_cover_addr_0;

        //Wrapper over the coverage group covering the indices in the paddr signal at which the bit of the paddr was 1
        uvm_ext_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH) wrap_cover_addr_1;
        
        //Wrapper over the coverage group covering the indices in the paddr signal at which the bit of the wdata was 0
        uvm_ext_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH) wrap_cover_wdata_0;

        //Wrapper over the coverage group covering the indices in the paddr signal at which the bit of the wdata was 1
        uvm_ext_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH) wrap_cover_wdata_1;

        //Wrapper over the coverage group covering the indices in the paddr signal at which the bit of the rdata was 0
        uvm_ext_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH) wrap_cover_rdata_0;

        //Wrapper over the coverage group covering the indices in the paddr signal at which the bit of the rdata was 1
        uvm_ext_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH) wrap_cover_rdata_1;

        // Register the apb coverage class with the factory
        `uvm_copmonent_utils(apb_coverage);

        
        // covergroup for the APB coverage
        covergroup cover_item with function sample(apb_item_mon item);
            option.per_instance = 1;
            direction: coverpoint item.direction {
                option.comment = "Direction of the transaction";
            }
            response : coverpoint item.response {
                option.comment = "response of the transaction";
            }
            length: coverpoint item.length {
                option.comment = "Length of the transaction";
                bins length_eq_2 = {2};
                bins lenght_le_10 [8] = {[3:10]}
                bins length_gt_10 = {[11:$]};

                illegal_bins length_illegal = {[$,1]};
            }
            response_cross_direction: cross direction, response;
            direction_transition: coverpoint item.direction{
                option.comment = "Transition of APB direction";
                bins direction_transtion [] = {APB_READ , APB_WRITE => APB_READ , APB_WRITE};
            }
            prev_item_delay: coverpoint item.prev_item_delay{
                option.comment = "Delay between 2 consecutive APB transaction"
                bins back2back = {0};
                bins delay_le_5[5] = {[1:5]};
                bins delay_gt_5 = {[6:$]};
            }
        endgroup

        covergroup cover_reset with function sample(bit psel);
            option.per_instance = 1;
      
            access_ongoing : coverpoint psel {
                option.comment = "An APB access was ongoing at reset";
            }
        endgroup

        function new (string name = "apb_coverage", uvm_component parent = null);
            super.new(name, parent);
            cover_item = new();
            cover_item.set_inst_name($sformatf("%0s %0s", get_full_name(), "cover_item")); 

            cover_reset = new(); 
            cover_rest.set_inst_name($sformatf("%0s %0s", get_full_name(), "cover_reset"));
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            wrap_cover_addr_0  = uvm_ext_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH)::type_id::create("wrap_cover_addr_0", this);
            wrap_cover_addr_1  = uvm_ext_cover_index_wrapper#(`APB_MAX_ADDR_WIDTH)::type_id::create("wrap_cover_addr_1", this);
            wrap_cover_wdata_0 = uvm_ext_cover_index_wrapper#(`APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_wdata_0", this);
            wrap_cover_wdata_1 = uvm_ext_cover_index_wrapper#(`APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_wdata_1", this);
            wrap_cover_rdata_0 = uvm_ext_cover_index_wrapper#(`APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_rdata_0", this);
            wrap_cover_rdata_1 = uvm_ext_cover_index_wrapper#(`APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_rdata_1", this);
        endfunction

        virtual function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);
            if($cast(agent_config, super.agent_config) == 0) begin
                `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Could not cast %0s to %0s", 
                   super.agent_config.get_type_name(), apb_agent_config::type_id::type_name))
              end
        endfunction
        
        // Write function associated with the coverage_port
        virtual function void write_item(apb_item_mon item);
            cover_item.sample(item);

            for(int i = 0 ; i < `APB_MAX_ADDR_WIDTH; i++) begin
                if(item.addr[i]) begin
                    wrap_cover_addr_1.sample(i);
                end
                else begin
                    wrap_cover_addr_0.sample(i);
                end
            end

            for(int i = 0 ; i < `APB_MAX_DATA_WIDTH; i++) begin
                case(item.direction) 
                    APB_READ: begin
                        if(item.data[i]) begin
                            wrap_cover_rdata_1.sample(i);
                        end
                        else begin
                            wrap_cover_rdata_0.sample(i);
                        end
                    end
                    APB_WRITE: begin
                        if(item.data[i]) begin
                            wrap_cover_wdata_1.sample(i);
                        end
                        else begin
                            wrap_cover_wdata_0.sample(i);
                        end
                    end
                    default: begin
                        `uvm_error("ISSUE", $sformatf("Current version of the code does not support item.dir: %0s", item.dir.name()))
                    end
                endcase
            end
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            apb_vif vif = agent_config.get_vif();

            cover_reset.sample(vif.psel);
        endfunction

        // Function to convert the coverage to string (As i run simulation on EDA playground)
        virtual function string cov2str();
            string result = {
                $sformatf("\n    cover_item:                %0.3.2f%%", cover_item.get_inst_coverage()),
                $sformatf("\n    direction:                 %0.3.2f%%", cover_item.direction.get_inst_coverage()),
                $sformatf("\n    prev_item_delay:           %0.3.2f%%", cover_item.prev_item_delay.get_inst_coverage()),
                $sformatf("\n    length:                    %0.3.2f%%", cover_item.lenght.get_inst_coverage()),
                $sformatf("\n    response:                  %0.3.2f%%", cover_item.response.get_inst_coverage()),
                $sformatf("\n    response_cross_direction:  %0.3.2f%%", cover_item.response_cross_direction.get_inst_coverage()),
                $sformatf("\n    direction_transition:      %0.3.2f%%", cover_item.direction_transition.get_inst_coverage()),
                $sformatf("\n                                    "),
                $sformatf("\n    cover_reset:               %0.3.2f%%", cover_reset.get_inst_coverage()),
                $sformatf("\n    access_ongoing:            %0.3.2f%%", cover_reset.access_ongoing.get_inst_coverage())
                super.cov2str();
            };

            return result;           
        endfunction

    endclass

`endif 