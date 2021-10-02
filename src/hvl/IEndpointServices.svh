
/****************************************************************************
 * IEndpointServices.svh
 ****************************************************************************/

  
/**
 * Class: IEndpointServices
 * 
 * TODO: Add class documentation
 */
class IEndpointServices;
		
	virtual function void init(IEndpoint ep);
	endfunction
		
	// TODO: args()
		
	virtual function void shutdown();
	endfunction
		
	virtual function int add_time_cb(
		longint unsigned			simtime,
		longint						callback_id);
	endfunction
		
	virtual function void cancel_callback(
		longint						callback_id);
	endfunction
		
	virtual function longint unsigned get_time();
	endfunction
		
	virtual function int time_precision();
	endfunction
		
	virtual function void run_until_event();
	endfunction
		
	virtual function void hit_event();
	endfunction
		
	virtual function void idle();
	endfunction
		
endclass

