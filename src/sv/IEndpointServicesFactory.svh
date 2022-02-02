/****************************************************************************
 * IEndpointServicesFactory.svh
 ****************************************************************************/

  
/**
 * Class: IEndpointServicesFactory
 * 
 * TODO: Add class documentation
 */
class IEndpointServicesFactory;

	virtual function IEndpointServices create();
		$display("TbLink Error: IEndpointServicesFactory::create unimplemented");
		$finish();
		return null;
	endfunction

endclass


