
/****************************************************************************
 * SVLaunchTypeConnectLoopback.svh
 ****************************************************************************/

  
/**
 * Class: SVLaunchTypeConnectLoopback
 * 
 * TODO: Add class documentation
 */
class SVLaunchTypeConnectLoopback extends ILaunchType;

	function new();

	endfunction
	
	virtual function string name();
		return "connect.sv.loopback";
	endfunction
	
	virtual function IEndpoint launch(
		input ILaunchParams 		params,
		input IEndpointServices		services,
		output string				errmsg);
		TbLink tblink = TbLink::inst();
		IEndpoint dflt = tblink.getDefaultEp();
		
		if (dflt != null) begin
			SVEndpointLoopback ep;
			if ($cast(ep, dflt)) begin
				$display("Connected to loopback");
				return ep.peer_ep();
			end else begin
				return null;
			end
		end else begin
			$display("Note: default EP is null");
			return null;
		end
	endfunction
	
	virtual function ILaunchParams newLaunchParams();
		SVLaunchParams params = new();
		return params;
	endfunction		


endclass


