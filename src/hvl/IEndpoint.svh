
/****************************************************************************
 * IEndpoint.svh
 ****************************************************************************/

typedef class IEndpointServices;
  
/**
 * Class: IEndpoint
 * 
 * TODO: Add class documentation
 */
class IEndpoint;
	
	virtual function int init(
		IEndpointServices		ep_services);
		$display("TBLink Error: IEndpoint::init unimplemented");
		$finish(1);
	endfunction
	
	virtual function int is_init();
		$display("TBLink Error: IEndpoint::is_init unimplemented");
		$finish(1);
	endfunction
		

endclass


