/****************************************************************************
 * DpiInterfaceImplProxy.svh
 ****************************************************************************/

IInterfaceImpl prv_dpi_ifimpl_m[chandle];

function automatic chandle newDpiInterfaceImplProxy(IInterfaceImpl ifimpl);
	chandle proxy = tblink_rpc_DpiInterfaceImplProxy_new();
	prv_dpi_ifimpl_m[proxy] = ifimpl;
	return proxy;
endfunction

typedef class TbLinkInvokeB;

function automatic void tblink_rpc_DpiInterfaceImplProxy_invoke(
	chandle			proxy_h,
	chandle			ifinst_h,
	chandle			method_h,
	longint			call_id,
	chandle			params_h);
	IInterfaceImpl		ifimpl = prv_dpi_ifimpl_m[proxy_h];
	DpiInterfaceInst	ifinst = new(ifinst_h);
	DpiMethodType		method = new(method_h);
	DpiParamValVec		params = new(params_h);
		
	$display("tblink_rpc_invoke: params_h=%p", params_h);
	
	if (method.is_blocking() != 0) begin
		TbLink tblink = TbLink::inst();
		IParamVal params_val_c;
		IParamValVec params_c;
		TbLinkInvokeB	invoke_t;
			
		`ifndef VERILATOR
			if (!tblink.m_dispatcher_running) begin
				$display("TbLink Warning: Attempting to schedule a call before dispatcher is running");
			end
		`endif
			
		params_val_c = params.clone();
		$cast(params_c, params_val_c);
			
		// Invoke indirectly
		invoke_t = new(
				ifimpl,
				ifinst,
				method,
				call_id,
				params_c);
			
		// Know this never blocks
		tblink.queue_thread(invoke_t);
	end else begin
		// Invoke directly
		IInterfaceImpl ifimpl = ifinst.get_impl();
		IParamVal retval;
			
		retval = ifimpl.invoke_nb(
				ifinst,
				method,
				params);
		
		ifinst.invoke_rsp(call_id, retval);
	end	
	
endfunction
export "DPI-C" function tblink_rpc_DpiInterfaceImplProxy_invoke;

function automatic void tblink_rpc_DpiInterfaceImplProxy_init(chandle ifimpl_h, chandle ifinst_h);
	IInterfaceImpl		ifimpl = prv_dpi_ifimpl_m[ifimpl_h];
	DpiInterfaceInst	ifinst = new(ifinst_h);
	ifimpl.init(ifinst);
endfunction
export "DPI-C" function tblink_rpc_DpiInterfaceImplProxy_init;

import "DPI-C" context function chandle tblink_rpc_DpiInterfaceImplProxy_new();

