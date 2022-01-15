
/****************************************************************************
 * IEndpointListener.svh
 ****************************************************************************/

  
/**
 * Class: IEndpointListener
 * 
 * TODO: Add class documentation
 */
class IEndpointListener;

	virtual function void event_f(IEndpointEvent ev);
		$display("TbLink Error: IEndpointListener::event_f not implemented");
		$finish();
	endfunction

endclass


