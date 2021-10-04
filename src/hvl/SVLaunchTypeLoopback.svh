
/****************************************************************************
 * SVLaunchTypeLoopback.svh
 ****************************************************************************/

typedef class SVEndpointLoopback;
  
/**
 * Class: SVLaunchTypeLoopback
 * 
 * TODO: Add class documentation
 */
class SVLaunchTypeLoopback extends ILaunchType;

	function new();
		$display("SVLaunchTypeLoopback");
	endfunction
	
	virtual function string name();
		return "sv.loopback";
	endfunction
	
	virtual function IEndpoint launch(
		input ILaunchParams params,
		output string		errmsg);
		return SVEndpointLoopback::mk();
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


