/****************************************************************************
 * DpiEndpointServicesProxy.svh
 ****************************************************************************/

IEndpointServices prv_dpi_services_m[chandle];

function automatic chandle newDpiEndpointServicesProxy(
	IEndpointServices services);
	chandle proxy = tblink_rpc_DpiEndpointServicesProxy_new();
	prv_dpi_services_m[proxy] = services;
	return proxy;
endfunction
	
import "DPI-C" context function chandle tblink_rpc_DpiEndpointServicesProxy_new();

function automatic void tblink_rpc_DpiEndpointServicesProxy_shutdown(chandle hndl);
	IEndpointServices services = prv_dpi_services_m[hndl];
	services.shutdown();
endfunction
export "DPI-C" function tblink_rpc_DpiEndpointServicesProxy_shutdown;

function automatic void tblink_rpc_DpiEndpointServicesProxy_run_until_event(chandle hndl);
	IEndpointServices services = prv_dpi_services_m[hndl];
	services.run_until_event();
endfunction
export "DPI-C" function tblink_rpc_DpiEndpointServicesProxy_run_until_event;

function automatic void tblink_rpc_DpiEndpointServicesProxy_hit_event(chandle hndl);
	IEndpointServices services = prv_dpi_services_m[hndl];
	services.hit_event();
endfunction
export "DPI-C" function tblink_rpc_DpiEndpointServicesProxy_hit_event;

function automatic void tblink_rpc_DpiEndpointServicesProxy_idle(chandle hndl);
	IEndpointServices services = prv_dpi_services_m[hndl];
	services.idle();
endfunction
export "DPI-C" function tblink_rpc_DpiEndpointServicesProxy_idle;

