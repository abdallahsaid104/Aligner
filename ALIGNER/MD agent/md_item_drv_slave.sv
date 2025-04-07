`ifndef MD_ITEM_DRV_SLAVE_SV
    `define MD_ITEM_DRV_SLAVE_SV

    class md_item_drv_slave extends md_item_drv;
        `uvm_object_utils(md_item_drv_slave)

        /*
            Control after how many cycles the  ready signal will be high.
            A vvalue off 0 means that the MD transaction will be only 1 cycle.
        */
        rand int unsigned length;

        rand md_response response;

        rand bit ready_at_end;

        constraint legth_default{
            soft length <=5;
        }        

        function new(string name = "md_item_drv_slave")
            super.new(name);
        endfunction

        virtual function string conv2str();
            return $sformatf("length:%0d , response:%0s , ready_at_end:%0d", length, response.name(), ready_at_end);
        endfunction
    endclass

`endif 