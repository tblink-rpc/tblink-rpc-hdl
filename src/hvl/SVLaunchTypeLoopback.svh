
/****************************************************************************
 * SVLaunchTypeLoopback.svh
 ****************************************************************************/

  
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
	endfunction
	
	virtual function ILaunchParams newLaunchParams();
		SVLaunchParams params = new();
		return params;
	endfunction	

endclass

static bit prv_SVLaunchTypeLoopback_rgy = SVLaunchTypeRegistration #(SVLaunchTypeLoopback)::register();


