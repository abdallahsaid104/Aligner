`ifndef AKIGNER_REG_ADAPTER_SV
    `define AKIGNER_REG_ADAPTER_SV

    class Aligner_reg_adapter extends uvm_reg_adapter;
        `uvm_object_utils(Aligner_reg_adapter)

        function new(string name = "Aligner_reg_adapter");
            super.new(name);
        endfunction

        virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
            apb_item_mon item_mon;
            apb_item_drv item_drv;

            if($cast(item_mon, bus_item)) begin
                rw.kind = (item_mon.direction == APB_WRITE)? UVM_WRITE : UVM_READ;
                rw.addr = item_mon.addr;
                rw.data = item_mon.data;
                rw.status = (item_mon.response == APB_OK) ? UVM_IS_OK : UVM_NOT_OK;

            end
            else if($cast(item_drv, bus_item)) begin
                rw.kind   = (item_drv.direction == APB_WRITE)? UVM_WRITE : UVM_READ;
                rw.addr   = item_drv.addr;
                rw.data   = item_drv.data;
                rw.status = UVM_IS_OK;
            end
            else begin
                `uvm_fatal("ISSUE", $sformatf("Class type %s not supported", bus_item.get_type_name()))
            end

        endfunction


        virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
            apb_item_drv item = apb_item_drv::type_id::create("item");
            void'(item.randomize() with {
                item.direction == (rw.kind == UVM_WRITE) ? APB_WRITE : APB_READ;
                item.data      == rw.data;
                item.addr      == rw.addr;
            })
            return item;
        endfunction
        
    endclass

`endif