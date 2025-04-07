`ifndef ALIGNER_REG_ACCESS_STATUS_INFO_SV
    `define  ALIGNER_REG_ACCESS_STATUS_INFO_SV

    class Aligner_reg_access_status_info;

    const uvm_status_e status;

    const string info;

    function new(uvm_status_e status, string info);
        this.status = status;
        this.info = info;
    endfunction

    static function Aligner_reg_access_status_info new_instance(uvm_status_e status, string info);
        Aligner_reg_access_status_info result = new(status, info);
        return result;
    endfunction
    endclass

`endif