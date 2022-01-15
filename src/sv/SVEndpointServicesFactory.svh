/****************************************************************************
 * SVEndpointServicesFactory.svh
 ****************************************************************************/

  
/**
 * Class: SVEndpointServicesFactory
 * 
 * TODO: Add class documentation
 */
class SVEndpointServicesFactory extends IEndpointServicesFactory;

	virtual function IEndpointServices create();
		SVEndpointServices services = new();
		return services;
	endfunction

endclass


