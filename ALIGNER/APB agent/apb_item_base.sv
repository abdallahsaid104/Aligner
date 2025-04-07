///////////////////////////////////////////////////////////////////////////////
// File:        apb_item_base.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Apb item base class.
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_ITEM_BASE_SV
    `define APB_ITEM_BASE_SV

    class apb_item_base extends uvm_sequence_item ;

        // Register the apb base item class with the factory
        uvm_object_utils(apb_item_base);
        
        // Direction
        rand apb_direction direction;

        // Address
        rand apb_addr addr;

        // Data
        rand apb_data data;

        function new (string name = "apb_item_base");
            super.new(name);
        endfunction

        virtual function string conv2str();
            string result = $sformatf("dir: %0s, addr: %0x", dirction.name(), addr);
      
            return result;
        endfunction

    endclass
`endif 