`ifndef ALIGNER_ENV_SV
    `define ALIGNER_ENV_SV

    class Aligner_env#(int unsigned DATA_WIDTH = 32) extends uvm_env implements uvm_ext_reset_handler;

        // Environmet config handle
        Aligner_env_config env_config;

        // APB Agent handler
        apb_agent apb_agent;

        // MD RX agent handler
        md_agent_master #(DATA_WIDTH) md_rx_agent;

        // MD RX agent handler
        md_agent_slave #(DATA_WIDTH) md_tx_agent;

        // Model handler
        Aligner_model model;

        // Predictor handler
        Aligner_reg_predictor#(apb_item_mon) predictor;

        // Scoreboard handler
        Aligner_scoreboard scoreboard;

        // Coverage handler
        Aligner_coverage coverage;

        // Virtual sequencer handler
        Aligner_virtual_sequencer virtual_sequencer;

        // Register the environment class with the factory
        uvm_copmonent_param_utils(Aligner_env#(DATA_WIDTH));

        function new (string name = "Aligner_env", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        virtual function build_phase(uvm_phase phase);
            super.build_phase(phase);

            env_config = Aligner_env_config::type_id::create("env_config", this);
            env_config.set_has_checks(1);
            env_config.set_algn_data_width(DATA_WIDTH);

            apb_agent = apb_agent::type_id::create("apb_agent",this);

            md_rx_agent = md_agent_master#(DATA_WIDTH)::type_id::create("md_rx_agent", this);

            begin 
                md_agent_config_slave#(DATA_WIDTH) agent_config = md_agent_config_slave#(DATA_WIDTH)::type_id::create("agent_config", this);
                agent_config.set_stuck_threshold(100);

                uvm_config_db#(uvm_ext_pkg::uvm_ext_agent_config#(.VIRTUAL_IF(virtual md_id#(DATA_WIDTH))))::set(this,"md_tx_agent","agent_config", agent_config);

            end
            md_tx_agent = md_agent_slave#(DATA_WIDTH)::type_id::create("md_tx_agent", this);

            model = Aligner_model::type_id::create("model", this);

            predictor = Aligner_reg_predictor#(apb_item_mon)::type_id::create("predictor", this);

            scoreboard = Aligner_scoreboard::type_id::create("scoreboard", this);

            model.port_out_rx.connect(scoreboard.port_in_model_rx);
            model.port_out_tx.connect(scoreboard.port_in_model_tx);
            model.port_out_irq.connect(scoreboard.port_in_model_irq);
            
            md_rx_agent.mon_port.connect(scoreboard.port_in_agent_rx);
            md_tx_agent.mon_port.connect(scoreboard.port_in_agent_tx);

            if(env_config.get_has_coverage()) begin
                coverage = Aligner_coverage::type_id::create("coverage", this);
            end

            virtual_sequencer = Aligner_virtual_sequencer::type_id::create("virtual_sequencer", this);
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            algn_vif vif;
            Aligner_reg_adapter adapter = Aligner_reg_adapter::type_id::create("adapter", this);
            super.connect_phase(phase);
            if(!uvm_config_db#(algn_vif)::get(this, "" , "vif", vif)) begin
                `uvm_fatal("ISSUE", "could not get the vif from the database")
            end
            else begin
                env_config.set_vif(vif);
            end
            
            predictor.map = model.reg_block.default_map;
            
            predictor.adapter = adapter;

            predictor.env_config = env_config;

            apb_agent.monitor.mon_port.connect(predictor.bus_in);

            // Connect the APB sequencer to the address map in order to use the API of the registers to start APB transactions
            model.reg_block.default_map.set_sequencer(apb_agent.sequencer, adapter);

            model.env_config = env_config;

            md_rx_agent.monitor.mon_port.connect(model.port_in_rx);
            md_tx_agent.monitor.mon_port.connect(model.port_in_tx);

            scoreboard.env_config = env_config;

            if(coverage != null) begin
                coverage.port_in_split_info.connect(model.port_in_split_info);
            end

            virtual_sequencer.apb_sequencer = apb_agent.sequencer;
            virtual_sequencer.md_rx_sequencer = md_sequencer_base_master'(md_rx_agent.sequencer);
            virtual_sequencer.md_tx_sequencer = md_sequencer_base_slave'(md_tx_agent.sequencer);
            virtual_sequencer.model = model;

        endfunction

        virtual task run_phase(uvm_phase phase);
            super.run_phase(phase);

            forever begin
                wait_reset_start();
                handle_reset();
                wait_reset_end();
            end
        endtask

        virtual function void handle_reset(uvm_phase phase);
            model.handle_reset(phase);
            scoreboard.handle_reset(phase);
            if(coverage != null) begin
                ccoverage.handle_reset(phase);
            end
        endfunction

        //Task for waiting reset to start
        protected virtual task wait_reset_start();
            apb_agent.agent_config.wait_reset_start();
        endtask

        //Task for waiting reset to end
        protected virtual task wait_reset_end();
            apb_agent.agent_config.wait_reset_end();
        endtask

    endclass
`endif 