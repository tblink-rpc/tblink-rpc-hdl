/****************************************************************************
 * TbLinkLaunchUvmObj.svh
 ****************************************************************************/

  
/**
 * Class: TbLinkLaunchUvmObj
 * 
 * TODO: Add class documentation
 */
class TbLinkLaunchUvmObj #(
		type Tp,			// Proxy-class type
		type Tbase=Tp::ImplT) extends Tbase;
	
	TbLinkAgentConfig			m_cfg;
	
	function new(string name="TbLinkLaunchUvmObj");
		super.new(name);
	endfunction
	
	function set_config(TbLinkAgentConfig cfg);
		m_cfg = cfg;
	endfunction
	
	task launch();
		TbLink tblink = TbLink::inst();
		IEndpointServicesFactory eps_f = tblink.getDefaultServicesFactory();
		IInterfaceTypeRgy iftype_rgy;
		Tp ifimpl;
		IEndpoint ep;
		IInterfaceType iftype;
		IInterfaceInst ifinst;
		IParamValVec params_m;
		ILaunchParams params;
		ILaunchType launch_t;
		IEndpointServices eps;
		IParamVal retval;
		int ret;
		string errmsg;
		
		iftype_rgy = InterfaceTypeRgyBase #(Tp::IfFactT)::inst();
		
		// TODO: Find launch type
		launch_t = tblink.findLaunchType(m_cfg.launch_type);
		
		if (launch_t == null) begin
			`uvm_fatal("TbLinkAgent", $sformatf("Failed to find launch type %0s", 
					m_cfg.launch_type));
			return;
		end
	
		// TODO: Configure launcher parameters
		params = launch_t.newLaunchParams();
		
		foreach (m_cfg.launch_args[i]) begin
			params.add_arg(m_cfg.launch_args[i]);
		end
		foreach (m_cfg.launch_params[k]) begin
			params.add_param(k, m_cfg.launch_params[k]);
		end

		// TODO: Launch
		$display("--> Calling launcher for %0s", m_cfg.launch_type);
		ep = launch_t.launch(params, null, errmsg);
		$display("<-- Calling launcher");
		
		if (ep == null) begin
			`uvm_fatal("TbLinkLaunchSeqBase", $sformatf("Failed to launch type %0s (%0s)",
					m_cfg.launch_type, errmsg));
			return;
		end
		
		// TODO: Configure endpoint with services
		eps = eps_f.create();
		
		$display("TbLinkAgent: eps=%0p", eps);
		
		if (eps == null) begin
			`uvm_fatal("TbLinkLaunchSeqBase", "null services handle");
			return;
		end
		
		if (ep.init(eps) == -1) begin
			`uvm_fatal("TbLinkLaunchSeqBase", $sformatf("init failed"));
			return;
		end		
		
		// TODO: Register type with endpoint
		iftype = iftype_rgy.defineType(ep);
		
		// TODO: Create implementation and proxy for ifinst
		ifimpl = new(this);
		
		// TODO: Create ifinst on endpoint
		//       - How do we know whether it's a mirror or not?
		ifinst = ep.defineInterfaceInst(
				iftype, // Need to get type
				"inst",
				0, // We aways deal with non-mirror interfaces
				ifimpl);
		
		// TODO: Complete 'build'
		$display("post_build_phase");
		
		if (ep.build_complete() == -1) begin
			`uvm_fatal("TbLinkLaunchSeqBase", $sformatf("Build stage failed"));
			return;
		end
		
		do begin
			ret = ep.is_build_complete();
			if (ret == 0) begin
				if (ep.process_one_message() == -1) begin
					ret = -1;
				end else begin
					#0;
				end
			end
		end while (ret == 0);
		
		if (ret == -1) begin
			`uvm_fatal("TbLinkLaunchSeqBase", "is_build_complete failed");
			return;
		end		
		
		// TODO: Complete 'connect'
		$display("post_connect_phase");
	
		if (ep.connect_complete() == -1) begin
			`uvm_fatal("TbLinkLaunchSeqBase", $sformatf("Connect stage failed"));
			return;
		end
		
		do begin
			ret = ep.is_connect_complete();
			if (ret == 0) begin
				if (ep.process_one_message() == -1) begin
					ret = -1;
				end else begin
					#0;
				end
			end
		end while (ret == 0);
		
		if (ret == -1) begin
			`uvm_fatal("TbLinkLaunchUvmObj", "is_connect_complete failed");
			return;
		end		
		
	endtask
	
	function bit shutdown();
	endfunction

endclass



