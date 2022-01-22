/****************************************************************************
 * TbLinkAgent.svh
 ****************************************************************************/


/**
 * Class: TbLinkAgent
 * 
 * TODO: Add class documentation
 */
class TbLinkAgent extends uvm_component;
	`uvm_component_utils(TbLinkAgent)
	
	IEndpoint				m_ep;
	bit						m_post_connect;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function bit init(TbLinkAgentConfig	cfg);
		TbLink tblink = TbLink::inst();
		ILaunchParams params;
		ILaunchType launch_t;
		IEndpointServicesFactory eps_f = tblink.getDefaultServicesFactory();
		IEndpointServices eps;
		int ret;
		string errmsg;
		
		$display("TbLinkAgent: build_phase");
		
		launch_t = tblink.findLaunchType(cfg.launch_type);
		
		if (launch_t == null) begin
			`uvm_fatal("TbLinkAgent", $sformatf("Failed to find launch type %0s", 
					cfg.launch_type));
			return 0;
		end
	
		params = launch_t.newLaunchParams();
		
		foreach (cfg.launch_args[i]) begin
			params.add_arg(cfg.launch_args[i]);
		end
		foreach (cfg.launch_params[k]) begin
			params.add_param(k, cfg.launch_params[k]);
		end

		$display("--> Calling launcher for %0s", cfg.launch_type);
		m_ep = launch_t.launch(params, null, errmsg);
		$display("<-- Calling launcher");
		
		if (m_ep == null) begin
			`uvm_fatal("TbLinkAgent", $sformatf("Failed to launch type %0s (%0s)",
					cfg.launch_type, errmsg));
			return 0;
		end
	
		// Complete 'init'
		// - Use default Services
		// - Complete is_init handshake
		eps = eps_f.create();
		
		$display("TbLinkAgent: eps=%0p", eps);
		
		if (eps == null) begin
			`uvm_fatal("TbLinkAgent", "null services handle");
			return 0;
		end
		
		if (m_ep.init(eps) == -1) begin
			`uvm_fatal("TbLinkAgent", $sformatf("init failed"));
			return 0;
		end

		/*
		do begin
			ret = m_ep.is_init();
		end while (ret == 0);
		
		if (ret != 1) begin
			`uvm_fatal("TbLinkAgent", $sformatf("is_init failed"));
			return 0;
		end
		 */
		
		// TODO: set EP as a configuration item
		
		
		return 1;
	endfunction
	
//	function void phase_started(uvm_phase phase);
//		$display("phase_started: %0s", phase.get_name());
//	endfunction
	
	function void phase_ended(uvm_phase phase);
		// Can get strange behavior when we call get_name
		// during shutdown
		if (m_post_connect) begin
			return;
		end
		
		if (phase.get_name() == "build") begin
			post_build_phase(phase);
		end else if (phase.get_name() == "connect") begin
			post_connect_phase(phase);
			m_post_connect = 1;
		end
	endfunction
	
	function void post_build_phase(uvm_phase phase);
		int ret;
		$display("post_build_phase");
		
		if (m_ep.build_complete() == -1) begin
			`uvm_fatal("TbLinkAgent", $sformatf("Build stage failed"));
			return;
		end
		
		do begin
			ret = m_ep.is_build_complete();
		end while (ret == 0);
		
		if (ret == -1) begin
			`uvm_fatal("TbLinkAgent", "is_build_complete failed");
			return;
		end
		
	endfunction
	
	function void post_connect_phase(uvm_phase phase);
		int ret;
		$display("post_connect_phase");
	
		if (m_ep.connect_complete() == -1) begin
			`uvm_fatal("TbLinkAgent", $sformatf("Connect stage failed"));
			return;
		end
		
		do begin
			ret = m_ep.is_connect_complete();
		end while (ret == 0);
		
		if (ret == -1) begin
			`uvm_fatal("TbLinkAgent", "is_connect_complete failed");
			return;
		end
	
	endfunction
	
	function void build_phase(uvm_phase phase);
		// Nothing to do here?
	endfunction
	
	function void connect_phase(uvm_phase phase);
	endfunction
	
	task run_phase(uvm_phase phase);
	endtask

endclass


