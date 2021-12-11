/****************************************************************************
 * SVEndpointServices.svh
 ****************************************************************************/

typedef class TbLink;
  
/**
 * Class: SVEndpointServices
 * 
 * Provides a basic SV implementation of endpoint services
 */
class SVEndpointServices extends IEndpointServices;
	IEndpoint			m_ep;

	function new();
	endfunction

	virtual function void init(IEndpoint ep);
		m_ep = ep;
	endfunction
		
	virtual function args(ref string argv[$]);
		argv = '{};
	endfunction
		
	virtual function void shutdown();
	endfunction
		
	virtual function int add_time_cb(
		longint unsigned			simtime,
		longint						callback_id);
		// TODO: Should be able to implement via TbLink singleton
		$display("TODO: SVEndpointServices::add_time_cb");
		return -1;
	endfunction
		
	virtual function void cancel_callback(
		longint						callback_id);
		// TODO: Should be able to implement via TbLink singleton
		$display("TODO: SVEndpointServices::cancel_callback");
	endfunction
		
	virtual function longint unsigned get_time();
		return $time;
	endfunction
		
	virtual function int time_precision();
		TbLink tblink = TbLink::inst();
		return tblink.getTimePrecision();
	endfunction
		
	virtual function void run_until_event();
	endfunction
		
	virtual function void hit_event();
	endfunction
		
	virtual function void idle();
	endfunction

endclass


