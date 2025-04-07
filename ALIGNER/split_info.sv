`ifndef SPLIT_INFO_SV
    `define SPLIT_INFO_SV
    
    class split_info extends uvm_object;

        int unsigned ctrl_offset;
        int unsigned ctrl_size;
        int unsigned md_offset;
        int unsigned md_size;
        int unsigned num_bytes_needed;
        
        `uvm_object_utils(split_info)

        function new(string name ="split_info" );
            super.new(name);
        endfunction

    endclass

`endif