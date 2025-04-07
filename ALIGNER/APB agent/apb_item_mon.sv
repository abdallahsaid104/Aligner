///////////////////////////////////////////////////////////////////////////////
// File:        apb_item_mon.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Apb monitor item class
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_ITEM_MON_SV
    `define APB_ITEM_MON_SV

    class apb_item_mon extends apb_item_base ;

        // Register the apb mon item class with the factory
        uvm_object_utils(apb_item_mon);

        // response
        apb_response response;

        // length : clock cycle of the APB transfer
        int unsigned length;


        // Previous item delay
        int unsigned prev_item_delay;

        function new (string name = "apb_item_mon");
            super.new(name);
        endfunction

        function string conv2str();
            string result = super.conv2str();

            if (direction == APB_WRITE) begin
                result = $sformatf("%s, data:%0x",result, data);
            end

            result = $sformatf("%s, data: %0x, response: %0d, length: %0d, prev_item_delay: %0d",
                                result, data, responece, length, prev_item_delay);

            return result;
        endfunction
        
    endclass
`endif 