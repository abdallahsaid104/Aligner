///////////////////////////////////////////////////////////////////////////////
// File:        apb_types.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: Types used by APB agent.
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_TYPES_SV
    `define APB_TYPES_SV

    // APB Virtual interface
    typedef virtual apb_if apb_vif;

    // APB Dirction (READ/WRITE)
    typedef enum bit {APB_READ, APB_WEITE} apb_direction;

    // APB Address
    typedef bit [`APB_MAX_ADDR_WIDTH-1 : 0 ] apb_addr;

    // APB Data
    typedef bit [`APB_MAX_DATA_WIDTH-1 : 0 ] apb_data;

    // APB Response
    typedef enum bit {APB_OK, APB_ERROR} apb_response; 

`endif 