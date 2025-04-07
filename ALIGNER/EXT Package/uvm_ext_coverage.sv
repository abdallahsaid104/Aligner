`ifndef UVM_EXT_COVERAGE_SV
    `define UVM_EXT_COVERAGE_SV

    `uvm_analysis_imp_decl(_item)

    virtual class uvm_ext_cover_index_wrapper_base extends uvm_component;

        function new(string name = "uvm_ext_cover_index_wrapper_base", uvm_component parent = null); 
            super.new(name, parent)
        endfunction

        pure virtual function void sample(int unsigned value);

        pure virtual function string cov2str();
    endclass

    class uvm_ext_cover_index_wrapper#(int unsigned MAX_VALUE_PLUS_1 = 16) extends uvm_ext_cover_index_wrapper_base;
        `uvm_component_param_utils(uvm_ext_cover_index_wrapper#(MAX_VALUE_PLUS_1))

        covergroup cover_index with function sample(int unsigned value);
        option.per_instance = 1

            index: coverpoint value {
                option.comment = "Index";
                bins values [MAX_VALUE_PLUS_1] = {[0:MAX_VALUE_PLUS_1]};
            }

        endgroup

        function new(string name = "uvm_ext_cover_index_wrapper", uvm_component parent = null); 
            super.new(name, parent);

            cover_index = new();
            cover_index.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_index"));
        endfunction

        virtual function string cov2str();
            string result = {
                $sformatf("\n    cover_index:                %0.3.2f%%", cover_index.get_inst_coverage()),
                $sformatf("\n    index:                      %0.3.2f%%", cover_index.index.get_inst_coverage())
            };
            return result
        endfunction

        virtual function void sample(int unsigned value);
            cover_index.sample(value);
        endfunction

    endclass

    class uvm_ext_coverage#(type VIRTUAL_IF = int, type ITEM_MON = uvm_sequence_item) extends uvm_component implements uvm_ext_reset_handler;

        uvm_ext_agent_config#(VIRTUAL_IF) agent_config;

        uvm_analysis_imp_item(ITEM_MON, uvm_ext_coverage#(VIRTUAL_IF,ITEM_MON)) coverage_port;

        uvm_component_param_utils(uvm_ext_coverage#(VIRTUAL_IF,ITEM_MON));

        function new(string name = "uvm_ext_coverage", uvm_component parent = null);
            super.new(name, parent);
            coverage_port = new("coverage_port", this);
        endfunction 

        virtual function void report_phase(uvn_phase phase);
            super.report_phase(phase);
            `uvm_info("DEBUG", $sformatf("Coverage: %0s", cov2str()), UVM_NONE)
        endfunction

        virtual function void write_item(ITEM_MON item);
        
        endfunction

        virtual function void handle_reset(uvm_phase phase);
      
        endfunction

        virtual function string cov2str();
            string result = "";

            uvm_component children[$];
            get_children(children);

            foreach(children[idx]) begin
                uvm_ext_cover_index_wrapper_base wrapper;
                if($cast(wrapper, children[idx])) begin
                    result = $sformatf("%s \n\n Child component: %0s%0s ", result, wrapper.get_name(), wrapper.cov2str());
                end
            end
            return result;
        endfunction
    endclass 

`endif 