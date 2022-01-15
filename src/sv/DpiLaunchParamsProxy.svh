/****************************************************************************
 * DpiLaunchParamsProxy.svh
 ****************************************************************************/

ILaunchParams prv_proxy_params_m[chandle];
 
function automatic chandle newLaunchParamsProxy(ILaunchParams params);
	chandle proxy = tblink_rpc_DpiLaunchParamsProxy_new();
	prv_proxy_params_m[proxy] = params;
	return proxy;
endfunction

function automatic void delLaunchParamsProxy(chandle proxy);
	prv_proxy_params_m.delete(proxy);
	tblink_rpc_DpiLaunchParamsProxy_del(proxy);
endfunction

function automatic void tblink_rpc_DpiLaunchParamsProxy_add_arg(
	chandle		proxy,
	string		arg);
	ILaunchParams params = prv_proxy_params_m[proxy];
	params.add_arg(arg);
endfunction
export "DPI-C" function tblink_rpc_DpiLaunchParamsProxy_add_arg;

function automatic void tblink_rpc_DpiLaunchParamsProxy_add_param(
	chandle		proxy,
	string		key,
	string		val);
	ILaunchParams params = prv_proxy_params_m[proxy];
	params.add_param(key, val);
endfunction
export "DPI-C" function tblink_rpc_DpiLaunchParamsProxy_add_param;

import "DPI-C" context function chandle tblink_rpc_DpiLaunchParamsProxy_new();
import "DPI-C" context function void tblink_rpc_DpiLaunchParamsProxy_del(
	chandle hndl);


