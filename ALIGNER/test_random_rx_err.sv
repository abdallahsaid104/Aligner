`ifndef TEST_RANDOM_RX_ERR_SV
  `define TEST_RANDOM_RX_ERR_SV

    class test_random_rx_err extends test_random;
    
        `uvm_component_utils(test_random_rx_err)
        
        function new(string name = "test_random_rx_err", uvm_component parent = null);
            super.new(name, parent);
        
            num_md_rx_transactions = 300;
        
            Aligner_virtual_sequence_rx::type_id::set_type_override(Aligner_virtual_sequence_rx_err::get_type());
        endfunction
     
  endclass
 
`endif  