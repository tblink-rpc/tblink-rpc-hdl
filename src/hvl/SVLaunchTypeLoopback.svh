
/****************************************************************************
 * SVLaunchTypeLoopback.svh
 ****************************************************************************/

typedef class SVEndpointLoopback;
  
/**
 * Class: SVLaunchTypeLoopback
 * 
 * Implements the launcher for the loopback-type endpoint
 */
class SVLaunchTypeLoopback extends ILaunchType;

	function new();
		$display("SVLaunchTypeLoopback");
	endfunction
	
	virtual function string name();
		return "sv.loopback";
	endfunction
	
	virtual function IEndpoint launch(
		input ILaunchParams 		params,
		input IEndpointServices		services,
		output string				errmsg);
		IEndpoint ep = SVEndpointLoopback::mk();
		
		if (services == null) begin
			// TODO: Use the default factory
		end
		
		ep.init(services);
		return ep;
	endfunction
	
	virtual function ILaunchParams newLaunchParams();
		SVLaunchParams params = new();
		return params;
	endfunction	

endclass

`ifdef UNDEFINED
function bit register_SVLaunchTypeLoopback();
	TbLink tblink = TbLink::inst();
	SVLaunchTypeLoopback launch_t = new();
	tblink.registerLaunchType(launch_t);
endfunction
static bit prv_SVLaunchTypeLoopback_rgy = register_SVLaunchTypeLoopback();
`endif


