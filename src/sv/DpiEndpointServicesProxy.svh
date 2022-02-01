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

function automatic int tblink_rpc_DpiEndpointServicesProxy_add_time_cb(
	chandle				hndl,
	longint unsigned	cb_time,
	longint				cb_id);
	IEndpointServices services = prv_dpi_services_m[hndl];
	return services.add_time_cb(cb_time, cb_id);
endfunction
export "DPI-C" function tblink_rpc_DpiEndpointServicesProxy_add_time_cb;

function automatic longint unsigned tblink_rpc_DpiEndpointServicesProxy_time(
	chandle				hndl);
	IEndpointServices services = prv_dpi_services_m[hndl];
	return services.get_time();
endfunction
export "DPI-C" function tblink_rpc_DpiEndpointServicesProxy_time;

function automatic void tblink_rpc_DpiEndpointServicesProxy_shutdown(chandle hndl);
	IEndpointServices services = prv_dpi_services_m[hndl];
	services.shutdown();
endfunction
export "DPI-C" function tblink_rpc_DpiEndpointServicesProxy_shutdown;


