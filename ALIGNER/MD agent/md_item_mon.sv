`ifndef MD_ITEM_MON_SV
    `define MD_ITEM_MON_SV

    class md_item_mon extends md_item_base;
        `uvm_object_utils(md_item_mon)

        int unsigned prev_item_delay;

        int unsigned length;

        bit [7 : 0] data[$];

        int unsigned offset;

        md_response response;

        function new(string name = "md_item_mon")
            super.new(name);
        endfunction

        virtual function string conv2str();
            string result = "{"

            foreach(data[idx]) begin
                result = $sformatf("%0s %02x%0s", result, data[idx], idx = data.size() - 1 ? "", ", " )
            end

            result = $sformatf("%0s}",result)

            return $sformatf("[%0t..%0s] data:%0s, offset:%0d, response:%0s, length:%0d, prev_item_delay:%0d",
                                get_begin_time(),
                                is_active()? "":$sformatf("%0t", get_end_time()),
                                result , offset, response.name(), length, prev_item_delay);
        endfunction
    endclass

`endif 