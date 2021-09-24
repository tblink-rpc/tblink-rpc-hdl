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
	
	typedef class IInterfaceTypeBuilder;
	typedef class IInterfaceType;
	typedef class IInterfaceInst;
	typedef class IEndpoint;
	typedef class IInterfaceImpl;
	typedef class IParamVal;
	
	class IInterfaceType;
		chandle			m_hndl;
	endclass

	import "DPI-C" context function chandle tblink_rpc_iftype_find_method(
			chandle		iftype_h,
			string		name);
	
	class IInvokeCall;
	endclass
	
	class IMethodType;
		chandle			m_hndl;
		
		function string name();
			return tblink_rpc_IMethodType_name(m_hndl);
		endfunction
		
		function longint id();
			return tblink_rpc_IMethodType_id(m_hndl);
		endfunction
	endclass
	
	import "DPI-C" context function string tblink_rpc_IMethodType_name(chandle hndl);
	import "DPI-C" context function longint tblink_rpc_IMethodType_id(chandle hndl);
	import "DPI-C" context function int unsigned tblink_rpc_IMethodType_is_export(chandle hndl);
	import "DPI-C" context function int unsigned tblink_rpc_IMethodType_is_blocking(chandle hndl);

	typedef class IParamValBool;
	typedef class IParamValVector;
	class IParamVal;
		chandle			m_hndl;
			
		typedef enum {
			Bool=0,
			Int,
			Map,
			Str,
			Vector
		} Type;
		
		function Type param_type();
			return Type'(_tblink_rpc_iparam_val_type(m_hndl));
		endfunction
		
		function IParamVal clone();
			chandle hndl = _tblink_rpc_iparam_val_clone(m_hndl);
			return mk(hndl);
		endfunction
		
		static function IParamVal mk(chandle hndl);
			IParamVal ret;
			case (_tblink_rpc_iparam_val_type(hndl))
				Bool: begin
					IParamValBool t = new();
					ret = t;
				end
				/*
				Int: begin
					ParamValInt t = new();
					ret = t;
				end
				Map: begin
					ParamValMap t = new();
					ret = t;
				end
				Str: begin
					ParamValStr t = new();
					ret = t;
				end
				 */
				Vector: begin
					IParamValVector t = new();
					ret = t;
				end
				default: begin
					$display("Error: unhandled value type");
					$finish();
				end
			endcase
			ret.m_hndl = hndl;
			return ret;
		endfunction
	endclass
	
	class IParamValBool extends IParamVal;
		
		function bit val();
			return (_tblink_rpc_iparam_val_bool_val(m_hndl) != 0);
		endfunction
		
		function IParamValBool clone();
			IParamValBool ret = new();
			ret.m_hndl = _tblink_rpc_iparam_val_clone(m_hndl);
			return ret;
		endfunction
		
	endclass
	
	class IParamValInt extends IParamVal;
		
	endclass
	
	class IParamValVector extends IParamVal;
		
		function int unsigned size();
			return _tblink_rpc_iparam_val_vector_size(m_hndl);
		endfunction
		
		function IParamVal at(int unsigned idx);
			// TODO: should use a factory to get types right on the SV side
			chandle hndl = _tblink_rpc_iparam_val_vector_at(m_hndl, idx);
			IParamVal ret = IParamVal::mk(hndl);
			return ret;
		endfunction
		
		function void push_back(IParamVal v);
			_tblink_rpc_iparam_val_vector_push_back(m_hndl, v.m_hndl);
		endfunction
		
		function IParamValVector clone();
			IParamValVector ret = new();
			ret.m_hndl = _tblink_rpc_iparam_val_clone(m_hndl);
			return ret;
		endfunction
	endclass
	
	class IParamValMap extends IParamVal;
	endclass
	
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

	class IInterfaceInst;
		chandle			m_hndl;
		
	endclass
	
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

	class InvokeInfo;
		chandle					m_hndl;
		
		function new(chandle hndl);
			m_hndl = hndl;
		endfunction
		
		function IInterfaceInst inst();
			IInterfaceInst ret = new();
			ret.m_hndl = tblink_rpc_InvokeInfo_ifinst(m_hndl);
			return ret;
		endfunction
		
		function IMethodType method();
			IMethodType ret = new();
			ret.m_hndl = tblink_rpc_InvokeInfo_method(m_hndl);
			return ret;
		endfunction
		
		function IParamValVector params();
			IParamValVector ret = new();
			ret.m_hndl = tblink_rpc_InvokeInfo_params(m_hndl);
			return ret;
		endfunction

		function void invoke_rsp();
			tblink_rpc_InvokeInfo_invoke_rsp(m_hndl, null);
		endfunction
		
	endclass
	
	import "DPI-C" context function chandle tblink_rpc_InvokeInfo_ifinst(chandle hndl);
	import "DPI-C" context function chandle tblink_rpc_InvokeInfo_method(chandle hndl);
	import "DPI-C" context function chandle tblink_rpc_InvokeInfo_params(chandle ii_h);
	import "DPI-C" context function void tblink_rpc_InvokeInfo_invoke_rsp(
			chandle 	ii_h,
			chandle		retval_h);
		
	
	class IInterfaceImpl;

		// This shouldn't be needed. However, there are some cases
		// where Verilator isn't able to determine the call scope
		// and needs to reach into the class hierarchy instead
		InvokeInfo m_ii;
		
		virtual function void invoke_nb(input InvokeInfo ii);
			$display("Error: invoke_nb not overridden");
			$finish();
		endfunction

		/*
		virtual function void invoke_nb_int();
			IEndpoint ep = IEndpoint::inst();
			chandle invoke_info_h = ep.get_invoke_info();
			IInterfaceInst inst = new IInterfaceInst();
			IMethodType method = new MethodType();
			longint call_id = _tblink_rpc_invoke_info_call_id(invoke_info_h);
			IParamValVector params = new IParamValVector();
			IParamVal retval;
			
			inst.m_hndl = _tblink_rpc_invoke_info_inst_h(invoke_info_h);
			method.m_hndl = _tblink_rpc_invoke_info_method_h(invoke_info_h);
			params.m_hndl = _tblink_rpc_invoke_info_params_h(invoke_info_h);
	
			retval = invoke_nb(inst, method, call_id, params);
			
			if (retval != null) begin
				_tblink_rpc_invoke_info_retval(retval.m_hndl);
			end
		endfunction
		 */
			
		
		virtual task invoke_b(input InvokeInfo ii);
			$display("Error: invoke not overridden");
			$finish();
		endtask
	
		/*
		virtual function void invoke_b_int();
			IEndpoint ep = IEndpoint::inst();
			chandle invoke_info_h = ep.get_invoke_info();
			IInterfaceInst inst = new IInterfaceInst();
			IMethodType method = new MethodType();
			longint call_id = _tblink_rpc_invoke_info_call_id(invoke_info_h);
			IParamValVector params = new IParamValVector();
			IParamVal retval;
			
			inst.m_hndl = _tblink_rpc_invoke_info_inst_h(invoke_info_h);
			method.m_hndl = _tblink_rpc_invoke_info_method_h(invoke_info_h);
			params.m_hndl = _tblink_rpc_invoke_info_params_h(invoke_info_h);
	
			invoke_b(inst, method, call_id, params);
			
			if (retval != null) begin
				_tblink_rpc_invoke_info_retval(retval.m_hndl);
			end
		endfunction
		 */
		
	endclass
	
	class IInterfaceTypeBuilder;
		chandle 		m_hndl;
		
		function IMethodType define_method(
			string					name,
			longint					id,
			string					signature,
			bit						is_export,
			bit						is_blocking);
			IMethodType ret = new();
			ret.m_hndl = _tblink_rpc_iftype_builder_define_method(
					m_hndl,
					name,
					id,
					signature,
					is_export?1:0,
					is_blocking?1:0);
			return ret;
		endfunction
	endclass
	
	// _Verilator didn't have support for static class 
	// members when this code was created. Re-check later
	IEndpoint		_endpoint;

	typedef class tblink_rpc_thread;
	typedef class tblink_rpc_timed_cb;
	typedef class tblink_rpc_invoke_b;
	

	/**
	 * Class: IEndpoint
	 */
	class IEndpoint;
		chandle					m_hndl;
		int unsigned			m_ifinst_id;
		IInterfaceImpl			m_ifimpl_m[chandle];
		chandle					m_ifinst_m[IInterfaceImpl];
		bit						m_started = 0;
		bit						m_running = 0;
`ifndef VERILATOR
		// Requests for new threads are queued here
		mailbox #(tblink_rpc_thread)   	m_thread_q = new();
		tblink_rpc_timed_cb				m_cb_m[chandle];
`endif
		InvokeInfo						m_next_ii;
		
		function new(chandle hndl);
			m_hndl = hndl;
		endfunction

		/** TODO:
		function int build_complete();
			return tblink_rpc_IEndpoint_build_complete(m_hndl);
		endfunction
		
		function int connect_complete();
			return tblink_rpc_IEndpoint_connect_complete(m_hndl);
		endfunction
		 */
		
		function int shutdown();
			return _tblink_rpc_endpoint_shutdown(m_hndl);
		endfunction
		
		function IInterfaceType findInterfaceType(string name);
			IInterfaceType ret;
			chandle if_h = tblink_rpc_IEndpoint_findInterfaceType(
					m_hndl,
					name);
			if (if_h != null) begin
				ret = new();
				ret.m_hndl = if_h;
			end
			return ret;
		endfunction
		
		function IInterfaceTypeBuilder newInterfaceTypeBuilder(string name);
			IInterfaceTypeBuilder ret = new();
			
			ret.m_hndl = tblink_rpc_IEndpoint_newInterfaceTypeBuilder(
						m_hndl,
						name);
			return ret;
		endfunction
		
		function IInterfaceType defineInterfaceType(IInterfaceTypeBuilder builder);
			IInterfaceType ret = new();
			ret.m_hndl = tblink_rpc_IEndpoint_defineInterfaceType(
					m_hndl,
					builder.m_hndl);
			return ret;
		endfunction
		
		
		function IInterfaceInst defineInterfaceInst(
			IInterfaceType			iftype,
			string					inst_name,
			int unsigned			is_mirror,
			IInterfaceImpl			ifinst_impl);
			IInterfaceInst ret = new();
			/*
			ret.m_hndl = tblink_rpc_IEndpoint_defineInterfaceInst(
				m_hndl,
				iftype.m_hndl,
				inst_name,
				is_mirror,
				ifinst_impl);
			
			m_ifimpl_m[ret.m_hndl] = ifinst_impl;
			m_ifinst_m[ifinst_impl] = ret.m_hndl;
			 */
			return ret;
		endfunction
	
`ifndef VERILATOR
		function void add_time_cb(
			chandle				cb_data,
			longint unsigned	delta);
			tblink_rpc_timed_cb cb = new(cb_data, delta);
		
			void'(m_thread_q.try_put(cb));
			m_cb_m[cb_data] = cb;
		endfunction
		
		task notify_time_cb(tblink_rpc_timed_cb cb);
			m_cb_m.delete(cb.m_cb_data);
			if (cb.m_valid) begin
				_tblink_rpc_notify_time_cb(cb.m_cb_data);
			end
		endtask
`endif

		static function IEndpoint inst();
			/*
			if (_endpoint == null) begin
				_endpoint = new();
				_endpoint.m_hndl = _tblink_rpc_endpoint_new(
					`ifdef VERILATOR
						0
					`else
						1
					`endif
				);
				
				if (_endpoint.m_hndl == null) begin
					$display("Error: failure initializing tblink_rpc");
					$finish();
				end
			end
			 */
			
			return _endpoint;
		endfunction

		// For environments with support for blocking tasks,
		// we need to run the main loop from within a task
		task run();
			// Multiple testbench sites are likely to call
			// run. Ignore all but the first.
			$display("==> Run %0d", m_running);
			if (!m_running) begin
				m_running = 1;

				// Launch 
				m_started = 1;
				if (_tblink_rpc_endpoint_launch(m_hndl) == 0) begin
					$display("Failed to launch TBLink frontend");
					$finish(1);
				end
`ifdef VERILATOR
				// TODO: anything needed here?
`else
				forever begin
					automatic tblink_rpc_thread t;
					m_thread_q.get(t);
					
					fork
						t.run();
					join_none
				end				
`endif
			end
		endtask
		
		function InvokeInfo get_invoke_info();
			InvokeInfo ret = m_next_ii;
			m_next_ii = null;
			return ret;
		endfunction
		
		function void set_invoke_info(InvokeInfo info);
			m_next_ii = info;
		endfunction
		
		function void _invoke_nb(InvokeInfo ii);
			chandle ifinst_h = tblink_rpc_InvokeInfo_ifinst(ii.m_hndl);
			IInterfaceImpl impl = m_ifimpl_m[ifinst_h];
			impl.m_ii = ii;
		
			m_next_ii = ii;
		
			impl.invoke_nb(ii);
		endfunction
		
		function void _invoke_b(InvokeInfo ii);
`ifndef VERILATOR
			tblink_rpc_invoke_b		closure;
			chandle ifinst_h = tblink_rpc_InvokeInfo_ifinst(ii.m_hndl);
			IInterfaceImpl impl = m_ifimpl_m[ifinst_h];
			/*
			IInterfaceInst inst = new();
			IMethodType method = new();
			IParamValVector params = new();
			
			$display("_invoke_b: call_id=%0d", call_id);
		
			inst.m_hndl = ifinst_h;
			method.m_hndl = method_h;
			params.m_hndl = params_h;
			 */
			
			closure = new(ii, impl);
			
			void'(m_thread_q.try_put(closure));
`else
			$display("Error: attempting to make a blocking call with Verilator");
			$finish();
`endif
		endfunction
	endclass

	/*
	chandle _endpoint_h = null;
	function automatic int _tblink_rpc_init();
		// Ensure that the endpoint singleton is constructed
		IEndpoint ep = IEndpoint::inst();
		return 1;
	endfunction
	int _init = _tblink_rpc_init();	
	 */
	
	/**
	 * tblink_rpc_run()
	 * 
	 * The run task must be called from a thread (eg initial) in the testbench
	 */
	task automatic tblink_rpc_run();
		IEndpoint ep = IEndpoint::inst();
		ep.run();
	endtask
	
	task automatic tblink_rpc_IEndpoint_start(chandle ep_h);
`ifndef VERILATOR
			// TODO: ensure launching thread is running
`endif
		$display("TODO: _start");
		if (_tblink_rpc_IEndpoint_start(ep_h) == -1) begin
			$display("TBLink Error: start failed");
			$finish(1);
		end
//		_tblink_rpc_IEndpoint_start(ep_h);
	endtask
		
	// IEndpoint functions
	import "DPI-C" context function chandle _tblink_rpc_endpoint_new(int have_blocking_tasks);
	import "DPI-C" context function chandle _tblink_rpc_endpoint_default();
	import "DPI-C" context function int _tblink_rpc_endpoint_launch(chandle ep_h);
	import "DPI-C" context function int tblink_rpc_IEndpoint_build_complete(chandle endpoint_h);
	import "DPI-C" context function int tblink_rpc_IEndpoint_connect_complete(chandle endpoint_h);
	import "DPI-C" context function int _tblink_rpc_IEndpoint_start(chandle endpoint_h);
	import "DPI-C" context function int _tblink_rpc_endpoint_shutdown(chandle endpoint_h);
	import "DPI-C" context function string tblink_rpc_IEndpoint_last_error(chandle endpoint_h);
	import "DPI-C" context function chandle tblink_rpc_IEndpoint_findInterfaceType(
			chandle		endpoint_h,
			string		name);
	import "DPI-C" context function chandle tblink_rpc_IEndpoint_newInterfaceTypeBuilder(
			chandle 	endpoint_h,
			string 		name);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeBool(
			chandle			iftype_b);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeInt(
			chandle			iftype_b,
			int unsigned	is_signed,
			int unsigned	width);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeMap(
			chandle			iftype_b,
			chandle			key_t,
			chandle			elem_t);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeStr(
			chandle			iftype_b);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeVec(
			chandle			iftype_b,
			chandle			elem_t);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_newMethodTypeBuilder(
			chandle			iftype_b,
			string			name,
			longint			id,
			chandle			rtype,
			int unsigned	is_export,
			int unsigned	is_blocking);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_add_method(
			chandle			iftype_b,
			chandle			mtb);
	
	import "DPI-C" context function chandle _tblink_rpc_iftype_builder_define_method(
			chandle			iftype_b,
			string			name,
			longint			id,
			string			signature,
			int unsigned	is_export,
			int unsigned	is_blocking);
	
	import "DPI-C" context function chandle tblink_rpc_IEndpoint_defineInterfaceType(
			chandle		endpoint_h,
			chandle 	iftype_builder_h);
	
	IInterfaceImpl				ifinst2impl_m[chandle];
	
	function chandle tblink_rpc_IEndpoint_defineInterfaceInst(
			chandle			endpoint_h,
			chandle			iftype_h,
			string			inst_name,
			int unsigned	is_mirror,
			IInterfaceImpl	impl);
		automatic chandle ifinst = _tblink_rpc_IEndpoint_defineInterfaceInst(
				endpoint_h,
				iftype_h,
				inst_name,
				is_mirror);
		ifinst2impl_m[ifinst] = impl;
		return ifinst;
	endfunction
	
	import "DPI-C" context function chandle _tblink_rpc_IEndpoint_defineInterfaceInst(
			chandle			endpoint_h,
			chandle			iftype_h,
			string			inst_name,
			int unsigned	is_mirror);
	
	function automatic void _tblink_rpc_invoke(
		chandle			invoke_info_h);
		chandle method_t = tblink_rpc_InvokeInfo_method(invoke_info_h);
		chandle ifinst = tblink_rpc_InvokeInfo_ifinst(invoke_info_h);
		
		$display("_tblink_rpc_invoke");
		
		if (tblink_rpc_IMethodType_is_blocking(method_t) != 0) begin
			// Invoke indirectly
			$display("Invoking Indirectly");
		end else begin
			// Invoke directly
			IInterfaceImpl ifimpl = ifinst2impl_m[ifinst];
			InvokeInfo ii = new(invoke_info_h);
			$display("Invoking Directly");
			
			ifimpl.invoke_nb(ii);
		end
	endfunction
	export "DPI-C" function _tblink_rpc_invoke;

	task automatic _tblink_rpc_invoke_b(
		chandle			invoke_info_h);
		IEndpoint ep = IEndpoint::inst();
		InvokeInfo ii = new(invoke_info_h);
		
		ep._invoke_b(ii);
	endtask
	export "DPI-C" task _tblink_rpc_invoke_b;
	
	
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
			IEndpoint ep;

			case (_time_precision)
				-15: #(m_delta*1fs);
				-12: #(m_delta*1ps);
				-9: #(m_delta*1ns);
				-6: #(m_delta*1us);
				-3: #(m_delta*1ms);
				0: #(m_delta*1s);
			endcase
			
			ep = IEndpoint::inst();
			ep.notify_time_cb(this);
		endtask
	endclass	
	
	class tblink_rpc_invoke_b extends tblink_rpc_thread;
		InvokeInfo				m_ii;
		IInterfaceImpl			m_impl;
		
		function new(
			InvokeInfo 			ii,
			IInterfaceImpl		impl);
			$display("tblink_rpc_invoke_b::new call_id=%0d", -1);
			m_ii = ii;
			m_impl = impl;
		endfunction
		
		virtual task run();
			IEndpoint ep = IEndpoint::inst();
			ep.set_invoke_info(m_ii);
			m_impl.invoke_b(m_ii);
			
			// TODO: dispose params

			tblink_rpc_InvokeInfo_invoke_rsp(m_ii.m_hndl, null);
		endtask
			
	endclass
	
`endif
	
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
	function void _tblink_rpc_add_time_cb(
		chandle				cb_data,
		longint unsigned	delta);
		automatic IEndpoint ep = IEndpoint::inst();
		
		ep.add_time_cb(cb_data, delta);
	endfunction
	export "DPI-C" function _tblink_rpc_add_time_cb;	

	import "DPI-C" context task _tblink_rpc_notify_time_cb(
		chandle				cb_data);
`endif /* !VERILATOR */
	
	
	function chandle tblink_rpc_bfm_find_iftype(string name);
		automatic IEndpoint ep = IEndpoint::inst();
		return tblink_rpc_IEndpoint_findInterfaceType(
			ep.m_hndl,
			name);
	endfunction
		
	function chandle tblink_rpc_bfm_new_iftype_builder(string name);
		automatic IEndpoint ep = IEndpoint::inst();
		return tblink_rpc_IEndpoint_newInterfaceTypeBuilder(
			ep.m_hndl,
			name);
	endfunction
		
	function chandle tblink_rpc_bfm_define_method(
		chandle			builder,
		string			name,
		longint			id,
		string			signature,
		int unsigned	is_export,
		int unsigned	is_blocking);
		return _tblink_rpc_iftype_builder_define_method(
					builder,
					name,
					id,
					signature,
					is_export,
					is_blocking);
	endfunction
		
	function chandle tblink_rpc_bfm_define_interface_type(
		chandle		iftype_builder);
		automatic IEndpoint ep = IEndpoint::inst();
		return tblink_rpc_IEndpoint_defineInterfaceType(
				ep.m_hndl,
				iftype_builder);
	endfunction
		
	function chandle tblink_rpc_bfm_define_interface_inst(
		chandle				iftype,
		string				name,
		IInterfaceImpl		impl);
		automatic IEndpoint ep = IEndpoint::inst();
		automatic chandle ifinst_h;

		/*
		ifinst_h = tblink_rpc_IEndpoint_defineInterfaceInst(
				ep.m_hndl,
				iftype,
				name);
				 */
			
		ep.m_ifimpl_m[ifinst_h] = impl;
		
		return ifinst_h;		
	endfunction

	import "DPI-C" context function chandle tblink_rpc_findLaunchType(string id);
	
	import "DPI-C" context function chandle tblink_rpc_newLaunchParams();
	
	import "DPI-C" context function void tblink_rpc_ILaunchParams_add_arg(
			input chandle	params,
			input string	arg);
	
	import "DPI-C" context function void tblink_rpc_ILaunchParams_add_param(
			input chandle	params,
			input string	key,
			input string	val);

	import "DPI-C" context function chandle tblink_rpc_ILaunchType_launch(
			input chandle	launch,
			input chandle 	params,
			output string	error);

endpackage

