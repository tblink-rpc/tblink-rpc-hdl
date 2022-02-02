
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
		
	virtual function void args(ref string argv[$]);
		argv = '{};
	endfunction
		
	virtual function void shutdown();
	endfunction
		
	virtual function int add_time_cb(
		longint unsigned			simtime,
		longint						callback_id);
		return -1;
	endfunction
		
	virtual function void cancel_callback(
		longint						callback_id);
	endfunction
		
	virtual function longint unsigned get_time();
		return -1;
	endfunction
		
	virtual function int time_precision();
		return -1;
	endfunction
		
endclass


