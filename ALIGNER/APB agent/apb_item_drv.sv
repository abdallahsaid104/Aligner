///////////////////////////////////////////////////////////////////////////////
// File:        apb_item_drv.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Apb item class that will be drived.
//              we need to randomize 5 fields:
//                  1 - direction
//                  2 - addr
//                  3 - data
//                  4 - pre drive delay
//                  5 - post drive delay
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_ITEM_DRV_SV
    `define APB_ITEM_DRV_SV

    class apb_item_drv extends apb_item_base ;

        // Register the apb drive item class with the factory
        uvm_object_utils(apb_item_drv);

        // Pre drive delay
        rand int unsigned pre_drive_delay;

        // Post drive delay
        rand int unsigned post_drive_delay;

        // Constraints for pre and post drive delay
        constraint pre_drive_delay_c {
            soft pre_drive_delay inside {[0:5]};
        }

        constraint post_drive_delay_c {
            soft post_drive_delay inside {[0:5]};
        }


        function new (string name = "apb_item_drv");
            super.new(name);
        endfunction

        function string conv2str();
            string result = super.conv2str();

            if (direction == APB_WRITE) begin
                result = $sformatf("%s, data:%0x",result, data);
            end

            result = $sformatf("%s, pre_drive_delay: %0d, post_drive_delay: %0d",result, pre_drive_delay, post_drive_delay);

            return result;
        endfunction
        
    endclass
`endif 