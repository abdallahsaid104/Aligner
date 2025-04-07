///////////////////////////////////////////////////////////////////////////////
// File:        app_if.sv
// Author:      Abdallah Said
// Date:        2025/03/11
// Description: APB interface module. It contains the APB interface signals.
///////////////////////////////////////////////////////////////////////////////
`ifndef APB_IF_SV
    `define APB_IF_SV

    `ifndef APB_MAX_DATA_WIDTH
        `define APB_MAX_DATA_WIDTH 32
    `endif

    `ifndef APB_MAX_ADDR_WIDTH
        `define APB_MAX_ADDR_WIDTH 16
    `endif

     
    interface apb_if(input pclk);
        logic preset_n;
        logic psel;
        logic penable;
        logic pwrite;
        logic [`APB_MAX_ADDR_WIDTH:0] paddr;
        logic [`APB_MAX_DATA_WIDTH:0] pwdata;
        logic [`APB_MAX_DATA_WIDTH:0] prdata;
        logic pready;
        logic pslverr;

        bit has_checks;

        initial begin
            has_checks = 1;
        end

        /* Setup Sequence in APB Transaction:
                There are 2 scenarios for the setup sequence:
                    1. When the psel signal is high and the past value of psel signal is low.
                    2. When the psel signal is high and the past value of pready signal is high.
        

        */
        sequence setup_phase;
            (psel == 1) && ($past(psel) == 0) || (psel == 1) && ($past(pready) == 1);
        endsequence

        /* Access Sequence in APB Transaction:
                There are 1 scenario for the access sequence:
                    1. When the psel signal is high and the also the penable signal is high.
        */
        sequence access_phase;
            (psel == 1) && (penable == 1);
        endsequence

        // property to make sure that the penable signal can not be high at the setup phase
        property penable_at_setup_phase;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            setup_phase |-> !penable ;
        endproperty
        PENALE_AT_SETUP_PHASE: assert property (penable_at_setup_phase) else
            $error("penable signal is high at the setup phase"); 
        
        // property to make sure that the penable signal is high in the access phase
            property penable_at_access_phase;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            setup_phase |=> penable;
        endproperty
        PENALE_AT_ACCESS_PHASE: assert property (penable_at_access_phase) else
            $error("penable signal is low at the access phase");
        
        // property to make sure that the penable signal is deasserted at the end of the access phase
        property penable_at_end_of_access_phase;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            access_phase and pready |=> !penable; 
        endproperty
        PENALE_AT_END_OF_ACCESS_PHASE: assert property (penable_at_end_of_access_phase) else
            $error("penable signal is high at the end of the access phase");
        
        // property to make sure that penable is stable during the access phase
        property penable_stable_at_access_phase;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            access_phase |-> penable;
        endproperty
        PENALE_STABLE_AT_ACCESS_PHASE: assert property (penable_stable_at_access_phase) else
            $error("penable signal is not stable during the access phase");

        // property to make sure that the paddr signal is stable during the access phase
        property paddr_stable_at_access_phase;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            access_phase |-> $stable(paddr);
        endproperty
        PADDR_STABLE_AT_ACCESS_PHASE: assert property (paddr_stable_at_access_phase) else
            $error("paddr signal is not stable during the access phase");

        // property to make sure that the pwrite signal is stable during the access phase
        property pwdata_stable_at_access_phase;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            access_phase |-> $stable(pwrite);
        endproperty
        PWDATA_STABLE_AT_ACCESS_PHASE: assert property (pwdata_stable_at_access_phase) else
            $error("pwdata signal is not stable during the access phase");
        
        // property to make sure that the pwdata signal is stable during the access phase
        property pwrite_stable_at_access_phase;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            access_phase and pwrite |-> $stable(pwdata);
        endproperty
        PWRITE_STABLE_AT_ACCESS_PHASE: assert property (pwrite_stable_at_access_phase) else
            $error("pwrite signal is not stable during the access phase");

        // property to make sure that the psel signal can not have unknown value
        property unknown_psel;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            $isunknown(psel)== 0 ;
        endproperty
        UNKNOWN_PSEL: assert property (unknown_psel) else
            $error("psel signal has unknown value");

        // property to make sure that the pready signal can not have unknown value
        property unknown_pready;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            psel |-> $isunknown(pready)== 0 ;
        endproperty
        UNKNOWN_PREADY: assert property (unknown_pready) else
            $error("pready signal has unknown value");
            
        // property to make sure that the pwrite signal can not have unknown value during APB transaction
        property unknown_pwrite;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            psel |-> $isunknown(pwrite)== 0 ;
        endproperty
        UNKNOWN_PWRITE: assert property (unknown_pwrite) else
            $error("pwrite signal has unknown value during APB transaction");
        
        // property to make sure that the penable signal can not have unknown value during APB transaction
        property unknown_penable;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            psel |-> $isunknown(penable)== 0 ;
        endproperty
        UNKNOWN_PENABLE: assert property (unknown_penable) else
            $error("penable signal has unknown value during APB transaction");
        
        // property to make sure that the paddr signal can not have unknown value during APB transaction
        property unknown_paddr;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            psel |-> $isunknown(paddr)== 0 ;
        endproperty
        UNKNOWN_PADDR: assert property (unknown_paddr) else
            $error("paddr signal has unknown value during APB transaction");
        
        // property to make sure that the pwdata signal can not have unknown value during APB transaction
        property unknown_pwdata;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            (psel && pwrite) |-> $isunknown(pwdata)== 0 ;
        endproperty
        UNKNOWN_PWDATA: assert property (unknown_pwdata) else
            $error("pwdata signal has unknown value during APB transaction");

        // property to make sure that the prdata signal can not have unknown value during APB transaction
        property unknown_prdata;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            (psel && !pwrite && pready && !pslverr) |-> $isunknown(prdata)== 0 ;
        endproperty
        UNKNOWN_PRDATA: assert property (unknown_prdata) else
            $error("prdata signal has unknown value during APB transaction");
        
            // property to make sure that the pslverr signal can not have unknown value when the response is ready
        property unknown_pslverr;
            @(posedge pclk) disable iff (!has_checks || !preset_n)
            (psel && pready) |-> $isunknown(pslverr)== 0 ;
        endproperty
        UNKNOWN_PSLVERR: assert property (unknown_pslverr) else
            $error("pslverr signal has unknown value");

     
    endinterface 

`endif 