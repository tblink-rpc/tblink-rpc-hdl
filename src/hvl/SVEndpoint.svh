
/****************************************************************************
 * SVEndpoint.svh
 ****************************************************************************/

  
/**
 * Class: SVEndpoint
 * 
 * TODO: Add class documentation
 */
class SVEndpoint extends IEndpoint;
	IEndpointServices			m_services;
	
	function new();
	endfunction
	
	virtual function int init(
		IEndpointServices		ep_services);
		m_services = ep_services;
		return 0;
	endfunction
	
	virtual function int is_init();
		return 0;
	endfunction


endclass


