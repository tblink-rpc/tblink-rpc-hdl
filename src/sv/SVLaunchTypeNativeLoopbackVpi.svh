/****************************************************************************
 * SVLaunchTypeNativeLoopbackVpi.svh
 ****************************************************************************/

  
/**
 * Class: SVLaunchTypeNativeLoopbackVpi
 * 
 * TODO: Add class documentation
 */
class SVLaunchTypeNativeLoopbackVpi extends ILaunchType;

	virtual function string name();
		return "native.loopback";
	endfunction
	
	virtual function IEndpoint launch(
		input ILaunchParams			params,
		input IEndpointServices		services,
		output string				errmsg);
		DpiEndpointLoopbackVpi ep = DpiEndpointLoopbackVpi::mk();
		TbLink tblink = TbLink::inst();
		int ret;
	
		// TODO: handle services
		// - Think we need a proxy if 'services' is specified on the input
		// - It's quite likely that TbLink will need to provide its own
		//   'services' in order to be able to determine how long to
		//   process messages, etc.
		
		// TODO: Register as SV and C++ default if 'is_default' is set
		begin
			ILaunchParams::string_m pm = params.params();
			if (params.has_param(string'("is_default")) && 
					params.get_param(string'("is_default")) == "1") begin
				tblink.setDefaultEp(ep);
				tblink_rpc_TbLink_setDefaultEP(
						tblink_rpc_TbLink_inst(),
						ep.m_hndl);
			end
		end
		
		tblink.addEndpoint(ep);
		tblink.addEndpoint(ep.peer());
		
		if (services == null) begin
			// TODO: construct default services
			TbLink tblink = TbLink::inst();
			IEndpointServicesFactory f = tblink.getDefaultServicesFactory();
			services = f.create();
		end
		
		$display("TODO: implement launch");
		ret = ep.init(services);
		
		return ep;
	endfunction

	virtual function ILaunchParams newLaunchParams();
		SVLaunchParams params = new();
		return params;
	endfunction

endclass


