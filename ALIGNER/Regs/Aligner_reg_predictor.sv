`ifndef ALIGNER_REG_PREDICTOR_SV
    `define ALIGNER_REG_PREDICTOR_SV

    class Aligner_reg_predictor#(type BUSTYPE = uvm_sequence_item) extends uvm_reg_predictor#(.BUSTYPE(BUSTYPE));

        Aligner_env_config env_config;

        `uvm_component_param_utils(Aligner_reg_predictor%(BUSTYPE))

        function new(string name ="Aligner_reg_predictor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        protected virtual function uvm_reg_data_t get_reg_field_value(uvm_reg_field field, uvm_reg_data_t reg_data);

        /*
        ---------------------------------------------------------------------------------------
        |31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|CLR|15|14|13|12|11|OFFSET|7|6|5|4|3| SIZE|
        ---------------------------------------------------------------------------------------
        ---------------------------------------------------------------------------------------
        |31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|9|8|7|6|5|4|3|2|1|0|
        ---------------------------------------------------------------------------------------

        ----> at first mask will be 
        ----------------------------------------------------------------
        |0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|
        ----------------------------------------------------------------
        ----> after the operation ('h1 << reg_field.get_n_bits()) ---> 1 left shift by the lenght of the field
              so in case of offset the mask after this operation will be
        ----------------------------------------------------------------
        |0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|1|0|0|0|
        ----------------------------------------------------------------
        ----> then subtract 1 (('h1 << reg_field.get_n_bits()) - 1)
        ----------------------------------------------------------------
        |0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|1|1|1|
        ----------------------------------------------------------------
        ----> then left sheft the mask by lsb_pos of the field (in case of offseet it will be 8)
        ----------------------------------------------------------------
        |0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|1|1|1|0|0|0|0|0|0|0|0|
        ----------------------------------------------------------------
        */
            uvm_reg_data_t mask = (('h1 << reg_field.get_n_bits()) - 1) << reg_field.get_lsb_pos();

        /*
        ----> at first result will be 
        ----------------------------------------------------------------
        |0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|
        ----------------------------------------------------------------
        ----> after the operation (mask & reg_data) (in case of offset)
        ----------------------------------------------------------------
        |0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|OFFSET|0|0|0|0|0|0|0|0|
        ----------------------------------------------------------------
        ----> then right shift the result by lsb_pos( in case of offset will be 8) so the return value will be
        ----------------------------------------------------------------
        |0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|OFFSET|
        ---------------------------------------------------------------- 
        SO we manage to get the fiekd value in the lsb bits of the temporary reg
        */
      
            return (mask & reg_data) >> reg_field.get_lsb_pos(); 
        endfunction


        protected virtual function uvm_status_e get_exp_response( uvm_reg_bus_op operation);

            uvm_reg register;
            register = map.get_reg_by_offset(operation.addr, (operation.kind == UVM_READ));

            //Any access to a location on which no register is mapped must reutrn an APB error
            if(register == null) begin
                return Aligner_reg_access_status_info::new_instance(UVM_NOT_OK, "access to a location on which no register is mapped");
            end

            //Any write access to a full read-only register must return an APB error.
            if(operation.kind == UVM_WRITE) begin
                uvm_reg_map_info info = map.uvm_get_reg_map_info(register);
                if(info.rights == "RO") begin
                    return Aligner_reg_access_status_info::new_instance(UVM_NOT_OK, "write access to a full read-only register");
                end
            end 

            //Any read access from a full write-only register must return an APB error.
            if(operation.kind ==  UVM_READ) begin
                uvm_reg_map_info info = map.uvm_get_reg_map_info(register);
                if(info.rights == "WO") begin
                    return Aligner_reg_access_status_info::new_instance(UVM_NOT_OK, "read access from a full write-only register");
                end
            end

            //Illegal write access to the Control register.
            if(operation.kind == UVM_WRITE) begin
               Aligner_reg_ctrl ctrl;
               if($cast(ctrl, register)) begin
                    uvm_reg_data_t size_value = get_reg_field_value(ctrl.SIZE, operation.data);
                    uvm_reg_data_t offset_value = get_reg_field_value(ctrl.OFFSET, operation.data);

                    //Trying to write value 0 in this field will return an APB error.
                    if(size_value == 0) begin
                        return Aligner_reg_access_status_info::new_instance(UVM_NOT_OK, "Trying to write value 0 in CTRL.SIZE");
                    end

                    //Trying to write an illegal combination of (SIZE, OFFSET) will return an APB error.
                    if((env_config.get_algn_data_width()/8 + offset_value) % size_value != 0) begin
                        return Aligner_reg_access_status_info::new_instance(UVM_NOT_OK,
                            $sformatf("Illegal access to CTRL---> OFFSET: %0d , SIZE:%0d , Aligner data width with: %0d",
                            offset_value, size_value, env_config.get_algn_data_width()));
                    end

               end
            end 

            return Aligner_reg_access_status_info::new_instance(UVM_NOT_OK,"All is ok");
        endfunction

        virtual function void write(BUSTYPE tr);
            uvm_reg_bus_op operation;
            adapter.bus2reg(tr, operation);

            if(env_config.get_has_checks()) begin
                Aligner_reg_access_status_info exp_response = get_exp_response(operation);

                if(exp_response.status != operation.status) begin
                    `uvm_error("DUT ERROR",
                    $sformatf("Mismatch detected for the bus operation status expected:%0s , recieved:%0s on access: %0s",
                    exp_response.name(), operation.status.name(), tr.cov2str()))
                end
            end

            if(operation.status == UVM_IS_OK) begin
                super.write(tr);
            end
            
        endfunction
    endclass

`endif 