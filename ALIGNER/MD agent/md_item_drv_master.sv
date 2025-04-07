`ifndef MD_ITEM_DRV_MASTER_SV
    `define MD_ITEM_DRV_MASTER_SV

    class md_item_drv_master extends md_item_drv;
        
    // Merging the data and size informations
        rand bit [ 7 : 0] data[$] 

        rand int unsigned offset;

        rand int unsigned pre_drv_delay;

        rand int unsigned post_drv_delay; 

        constraint pre_drv_delay_c {
            soft pre_drv_delay <= 5 ;
        }

        constraint post_drv_delay_c {
            soft post_drv_delay <= 5;
        }

        constraint data_default {
            soft data.size() == 1;
        }

        constraint data_hard {
            soft data.size() > 0;
        }

        constraint offset_default {
            soft offset == 0 ;
        }


        `uvm_object_utils(md_item_drv_master)

        
        function new(string name = "md_item_drv_master")
            super.new(name);
        endfunction

        virtual function string conv2str();
        /*
            { 'h0x11,'h0x22,'h0x33,'h0x44}
        */
            string result = "{"
            foreach (data[idx]) begin
                result = $sformatf("%0s 'h%02x%0s", result, data[idx], idx ==data.size() - 1 ? "" : ", ");
            end
            result = $sformatf("%0s}", result);
            return $sformatf("data: %0s , offset: %0d, pre_drv_delay: %0d, post_drv_delay: %0d", result , offset, pre_drv_delay, post_drv_delay);

        endfunction
    endclass
`endif