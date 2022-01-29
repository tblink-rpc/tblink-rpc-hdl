/****************************************************************************
 * DpiTbLinkListenerProxy.svh
 ****************************************************************************/

ITbLinkListener prv_dpi_tblink_listener_m[chandle];

function automatic chandle newDpiTbLinkListenerProxy(
	ITbLinkListener		listener);
	chandle proxy = tblink_rpc_DpiTbLinkListenerProxy_new();
	prv_dpi_tblink_listener_m[proxy] = listener;
	return proxy;
endfunction

import "DPI-C" context function chandle tblink_rpc_DpiTbLinkListenerProxy_new();

function automatic void tblink_rpc_DpiTbLinkListenerProxy_notify(
	chandle		proxy_h,
	chandle		ev_h);
	DpiTbLinkEvent ev = new(ev_h);
	ITbLinkListener l = prv_dpi_tblink_listener_m[proxy_h];
	l.notify(ev);
endfunction
export "DPI-C" function tblink_rpc_DpiTbLinkListenerProxy_notify;
  


