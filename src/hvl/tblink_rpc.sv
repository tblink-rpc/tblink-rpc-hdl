/****************************************************************************
 * tblink.sv
 * 
 * SystemVerilog integration shim for TBLink
 ****************************************************************************/
  
/**
 * Package: tblink_rpc
 * 
 * Provides API methods that user code is intended to call.
 * Also provides a Verilator-specific implementation 
 */
package tblink_rpc;
	
	// Initialize DPI context for package
	import "DPI-C" context function int _tblink_rpc_pkg_init(
			input int unsigned 		have_blocking_tasks,
			output int 				time_precision);
	
	int 			_time_precision = 0;
	int _init = _tblink_rpc_pkg_init(
`ifdef VERILATOR
			0,
`else
			1,
`endif
			_time_precision
			);

`ifdef VERILATOR
	// Dynamic cast currently has issues with Verilator
	// Specifically, seems to be an issue with no timeunit
//	`define DYN_CAST(tgt, src) $display("TBLink Error: Verilator doesn't support dynamic cast")
	`define DYN_CAST(tgt, src) $cast(tgt, src)
`else
	`define DYN_CAST(tgt, src) $cast(tgt, src)
`endif
	
	typedef class IInterfaceTypeBuilder;
	typedef class IInterfaceType;
	typedef class IInterfaceInst;
	typedef class IEndpoint;
	typedef class IInterfaceImpl;
	
	typedef class IParamVal;
	typedef class IParamValBool;
	typedef class IParamValVec;
	`include "IParamVal.svh"
	`include "IParamValBool.svh"
	`include "IParamValInt.svh"
	`include "IParamValVec.svh"
	`include "IParamValMap.svh"
	
	`include "IType.svh"
	`include "ITypeInt.svh"
	`include "ITypeMap.svh"
	`include "ITypeVec.svh"

	`include "IMethodTypeBuilder.svh"
	`include "IMethodType.svh"
	`include "IInterfaceTypeBuilder.svh"
	
	`include "IInterfaceType.svh"
	`include "IInterfaceInst.svh"
	`include "InvokeInfo.svh"
	`include "IInterfaceImpl.svh"
	`include "IEndpoint.svh"
	`include "IEndpointServices.svh"
	
	`include "ILaunchParams.svh"
	`include "ILaunchType.svh"
	
	`include "SVEndpoint.svh"

	`include "DpiType.svh"
	`include "DpiTypeInt.svh"
	`include "DpiTypeMap.svh"
	`include "DpiTypeVec.svh"
	`include "DpiInterfaceInst.svh"
	`include "DpiMethodTypeBuilder.svh"
	`include "DpiInterfaceTypeBuilder.svh"
	`include "DpiInterfaceType.svh"
	`include "DpiParamVal.svh"
	`include "DpiInvokeInfo.svh"
	`include "DpiLaunchParams.svh"
	`include "DpiLaunchType.svh"
	`include "DpiMethodType.svh"
	`include "DpiParamValBool.svh"
	
	
	`include "TbLink.svh"

	import "DPI-C" context function chandle tblink_rpc_iftype_find_method(
			chandle		iftype_h,
			string		name);
	
	import "DPI-C" context function longint _tblink_rpc_iparam_val_int_val_u(
			chandle			hndl);

	import "DPI-C" context function chandle _tblink_rpc_iparam_val_clone(
			chandle			hndl);
	import "DPI-C" context function int unsigned _tblink_rpc_iparam_val_type(
			chandle			hndl);
	
	import "DPI-C" context function int unsigned _tblink_rpc_iparam_val_bool_val(
			chandle			hndl);
	
	import "DPI-C" context function chandle _tblink_rpc_iparam_val_vector_new();

	import "DPI-C" context function int unsigned _tblink_rpc_iparam_val_vector_size(
			chandle			hndl);
	import "DPI-C" context function chandle _tblink_rpc_iparam_val_vector_at(
			chandle			hndl,
			int unsigned	idx);
	import "DPI-C" context function void _tblink_rpc_iparam_val_vector_push_back(
			chandle			hndl,
			chandle			val_h);

	
	import "DPI-C" context function string tblink_rpc_IInterfaceInst_name(
			chandle			ifinst);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_type(
			chandle			ifinst);
	import "DPI-C" context function int unsigned tblink_rpc_IInterfaceInst_is_mirror(
			chandle			ifinst);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValBool(
			chandle			ifinst,
			int unsigned	val);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValIntU(
			chandle				ifinst,
			longint unsigned	val,
			int unsigned		width);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValIntS(
			chandle				ifinst,
			longint				val,
			int unsigned		width);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValMap(
			chandle				ifinst);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValStr(
			chandle				ifinst,
			string				val);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValVec(
			chandle				ifinst);
	
	import "DPI-C" context function chandle _tblink_rpc_ifinst_invoke_nb(
			chandle			ifinst_h,
			chandle			method_h,
			chandle			params_h);


	

		
	
	
	IInterfaceImpl				ifinst2impl_m[chandle];
	
`ifndef VERILATOR
	
	/**
	 * tblink_rpc_thread
	 * 
	 * Base class for dynamically-created tblink-rpc threads
	 */
	class tblink_rpc_thread;
		function new();
		endfunction
	
		virtual task run();
			$display("Error: base run method invoked");
			$finish();
		endtask
	endclass
	
	mailbox #(tblink_rpc_thread)		prv_dispatch_q = new();
	bit prv_dispatcher_running = 0;
	
	task _tblink_dispatcher();
		tblink_rpc_thread t;
		
		forever begin
			prv_dispatch_q.get(t);
			t.run();
		end
	endtask
	
	function void _tblink_start_dispatcher();
		if (prv_dispatcher_running == 0) begin
			prv_dispatcher_running = 1;
			fork
				_tblink_dispatcher();
			join_none
		end
	endfunction
	
	/**
	 * tblink_rpc_timed_cb
	 * 
	 * Helper class to support timed callbacks
	 */
	class tblink_rpc_timed_cb extends tblink_rpc_thread;
		chandle					m_cb_data;
		longint unsigned		m_delta;
		bit						m_valid = 1;
		
		function new(
			chandle				cb_data,
			longint unsigned 	delta);
			m_cb_data = cb_data;
			m_delta = delta;
		endfunction
		
		virtual task run();

			case (_time_precision)
				-15: #(m_delta*1fs);
				-12: #(m_delta*1ps);
				-9: #(m_delta*1ns);
				-6: #(m_delta*1us);
				-3: #(m_delta*1ms);
				0: #(m_delta*1s);
			endcase
	
			_tblink_rpc_notify_time_cb(m_cb_data);
		endtask
	endclass	
	
	class tblink_rpc_invoke_b extends tblink_rpc_thread;
		InvokeInfo				m_ii;
	
		function new(InvokeInfo ii);
			m_ii = ii;
		endfunction
	
		virtual task run();
			IInterfaceInst ifinst = m_ii.inst();
			IInterfaceImpl ifimpl = ifinst.get_impl();
//			chandle ifinst = tblink_rpc_InvokeInfo_ifinst(m_ii.m_hndl);
//			IInterfaceImpl ifimpl = ifinst2impl_m[ifinst];

			$display("--> invoke_b");
			ifimpl.invoke_b(m_ii);
			$display("<-- invoke_b");
		endtask
	endclass
`else
	function void _tblink_start_dispatcher();
		$display("TODO: _tblink_start_dispatcher() for Verilator");
	endfunction
`endif /* ifndef VERILATOR */
	
	
	// _Verilator didn't have support for static class 
	// members when this code was created. Re-check later
	IEndpoint		_endpoint;

	
	class EndpointServicesDpi extends IEndpointServices;
	endclass
	
	`include "DpiEndpoint.svh"
	
	/**
	 * tblink_rpc_run()
	 * 
	 * The run task must be called from a thread (eg initial) in the testbench
	 */
	task automatic tblink_rpc_run();
		_tblink_start_dispatcher();
	endtask
	
	task automatic tblink_rpc_IEndpoint_start(chandle ep_h);
			// TODO: ensure launching thread is running
		$display("TODO: _start");
`ifndef VERILATOR
		_tblink_start_dispatcher();
`endif
		if (_tblink_rpc_IEndpoint_start(ep_h) == -1) begin
			$display("TBLink Error: start failed");
			$finish(1);
		end
//		_tblink_rpc_IEndpoint_start(ep_h);
	endtask
		
	// IEndpoint functions
	
	function automatic void _tblink_rpc_invoke(
		chandle			invoke_info_h);
		chandle method_t = tblink_rpc_InvokeInfo_method(invoke_info_h);
		chandle ifinst = tblink_rpc_InvokeInfo_ifinst(invoke_info_h);
		
		$display("_tblink_rpc_invoke");
		if (tblink_rpc_IMethodType_is_blocking(method_t) != 0) begin
`ifndef VERILATOR
			// Invoke indirectly
			DpiInvokeInfo ii = new(invoke_info_h);
			tblink_rpc_invoke_b t = new(ii);
			
			$display("Invoking Indirectly");
			// Know this never blocks
			void'(prv_dispatch_q.try_put(t));
`else
			$display("TBLink Error: attempting to call a blocking method in Verilator");
			$finish(1);
`endif
		end else begin
			// Invoke directly
			IInterfaceImpl ifimpl = ifinst2impl_m[ifinst];
			DpiInvokeInfo ii = new(invoke_info_h);
			$display("Invoking Directly");
			
			ifimpl.invoke_nb(ii);
		end
	endfunction
	export "DPI-C" function _tblink_rpc_invoke;

	task automatic _tblink_rpc_invoke_b(
		chandle			invoke_info_h);
	/* TODO:
		IEndpoint ep = IEndpoint::inst();
		InvokeInfo ii = new(invoke_info_h);
		
//		ep._invoke_b(ii);
 *  */
	endtask
	export "DPI-C" task _tblink_rpc_invoke_b;
	

	
`ifdef VERILATOR
	// For simplicity, we still provide the export
	// even though Verilator uses a different mechanism
	function void _tblink_rpc_add_time_cb(
		chandle				cb_data,
		longint unsigned	delta);
		$display("Error: tblink_register_timed_callback called from Verilator");
		$finish;
	endfunction
	export "DPI-C" function _tblink_rpc_add_time_cb;	
		
	task _tblink_rpc_notify_time_cb(chandle	cb_data);
		$display("Error: tblink_rpc_notify_time_callback called");
		$finish;
	endtask
`else
	function automatic void _tblink_rpc_add_time_cb(
		chandle				cb_data,
		longint unsigned	delta);
		tblink_rpc_timed_cb t = new(cb_data, delta);
		void'(prv_dispatch_q.try_put(t));
	endfunction
	export "DPI-C" function _tblink_rpc_add_time_cb;	

	import "DPI-C" context task _tblink_rpc_notify_time_cb(
		chandle				cb_data);
`endif /* !VERILATOR */
	
	
	function chandle tblink_rpc_bfm_find_iftype(string name);
	/* TODO:
		automatic IEndpoint ep = IEndpoint::inst();
		return tblink_rpc_IEndpoint_findInterfaceType(
			ep.m_hndl,
			name);
			 */
	return null;
	endfunction
		
	function chandle tblink_rpc_bfm_new_iftype_builder(string name);
	/*
		automatic IEndpoint ep = IEndpoint::inst();
		return tblink_rpc_IEndpoint_newInterfaceTypeBuilder(
			ep.m_hndl,
			name);
			 */
	return null;
	endfunction
	
	function chandle tblink_rpc_bfm_define_method(
		chandle			builder,
		string			name,
		longint			id,
		string			signature,
		int unsigned	is_export,
		int unsigned	is_blocking);
`ifdef UNDEFINED
		return _tblink_rpc_iftype_builder_define_method(
					builder,
					name,
					id,
					signature,
					is_export,
					is_blocking);
`endif
	endfunction
		
	function chandle tblink_rpc_bfm_define_interface_type(
		chandle		iftype_builder);
	/*
		automatic IEndpoint ep = IEndpoint::inst();
		return tblink_rpc_IEndpoint_defineInterfaceType(
				ep.m_hndl,
				iftype_builder);
				 */
	return null;
	endfunction
		
	function chandle tblink_rpc_bfm_define_interface_inst(
		chandle				iftype,
		string				name,
		IInterfaceImpl		impl);
	/* TODO:
		automatic IEndpoint ep = IEndpoint::inst();
		automatic chandle ifinst_h;

		ep.m_ifimpl_m[ifinst_h] = impl;
		
		return ifinst_h;		
		 */
	 	return null;
	endfunction

	
	import "DPI-C" context function string tblink_rpc_libpath();

endpackage

