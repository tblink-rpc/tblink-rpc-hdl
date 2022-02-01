
/****************************************************************************
 * TbLinkLaunchSeqBase.svh
 ****************************************************************************/

  
/**
 * Class: TbLinkLaunchSeqBase
 * 
 * TODO: Add class documentation
 */
class TbLinkLaunchSeqBase #(
		type REQ=uvm_sequence_item, 
		type RSP=REQ) extends uvm_sequence #(REQ, RSP);
	TbLinkAgentConfig				m_cfg;

	virtual function void setConfig(TbLinkAgentConfig cfg);
		m_cfg = cfg;
	endfunction

	virtual task body();
		IInterfaceFactoryBase factory = get_factory();
		TbLink tblink = TbLink::inst();
		IEndpointServicesFactory eps_f = tblink.getDefaultServicesFactory();
		IInterfaceImplProxy proxy;
		IEndpoint ep;
		IInterfaceType iftype;
		IInterfaceInst ifinst;
		IMethodType body_m;
		IParamValVec params_m;
		ILaunchParams params;
		ILaunchType launch_t;
		IEndpointServices eps;
		IParamVal retval;
		int ret;
		string errmsg;
		
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
		iftype = factory.defineType(ep);
		
		body_m = iftype.findMethod("body");
		
		if (body_m == null) begin
			`uvm_fatal("TbLinkLaunchSeqBase", 
				$sformatf("Interface type %s doesn't define a 'body' method", iftype.name()));
			return;
		end
		
		// TODO: Create implementation and proxy for ifinst
		proxy = create_proxy();
		
		// TODO: Create ifinst on endpoint
		//       - How do we know whether it's a mirror or not?
		ifinst = ep.defineInterfaceInst(
				iftype, // Need to get type
				"inst",
				proxy.is_mirror(),
				proxy);
		
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
			`uvm_fatal("TbLinkLaunchSeqBase", "is_connect_complete failed");
			return;
		end		
		
		// TODO: Run 'body' method. 
		$display("TODO: run body method");
		params_m = ifinst.mkValVec();
		ifinst.invoke_b(
				retval, 
				body_m,
				params_m);
		
		// TODO: Shutdown when complete
		
	endtask
	
	virtual function IInterfaceFactoryBase get_factory();
		$display("TbLink Error: TbLinkLaunchSeqBase::get_factory unimplemented");
		$finish(1);
		return null;
	endfunction
	
	virtual function IInterfaceImplProxy create_proxy();
		$display("TbLink Error: TbLinkLaunchSeqBase::create_proxy unimplemented");
		$finish(1);
		return null;
	endfunction


endclass


