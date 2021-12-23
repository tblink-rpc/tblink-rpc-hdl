/****************************************************************************
 * DpiEndpointListenerProxy.svh
 ****************************************************************************/

IEndpointListener prv_dpi_listener_m[chandle];
chandle prv_listener_dpi_m[IEndpointListener];

function automatic void connectDpiEndpointListenerProxy(
	chandle				ep_h,
	IEndpointListener 	l);
	chandle proxy = tblink_rpc_DpiEndpointListenerProxy_connect(ep_h);
	prv_dpi_listener_m[proxy] = l;
	prv_listener_dpi_m[l] = proxy;
endfunction

function automatic void disconnectDpiEndpointListenerProxy(
	chandle				ep_h,
	IEndpointListener 	l);
	chandle proxy = prv_listener_dpi_m[l];
	prv_listener_dpi_m.delete(l);
	prv_dpi_listener_m.delete(proxy);
	tblink_rpc_DpiEndpointListenerProxy_disconnect(ep_h, proxy);
endfunction
 
import "DPI-C" context function chandle tblink_rpc_DpiEndpointListenerProxy_connect(
	chandle		ep_h);

import "DPI-C" context function void tblink_rpc_DpiEndpointListenerProxy_disconnect(
	chandle		ep_h,
	chandle 	proxy_h);

function automatic void tblink_rpc_DpiEndpointListenerProxy_event(
	chandle hndl,
	chandle ev_h);
	DpiEndpointEvent ev = new(ev_h);
	IEndpointListener l = prv_dpi_listener_m[hndl];
	l.event_f(ev);
endfunction

export "DPI-C" function tblink_rpc_DpiEndpointListenerProxy_event;

