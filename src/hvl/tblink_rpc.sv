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
	import "DPI-C" context function chandle _tblink_rpc_pkg_init(
			input int have_blocking_tasks,
			output int time_precision);

	chandle _endpoint_h = null;
	int _time_precision = 0;
	function int _tblink_rpc_init();
		if (_endpoint_h == null) begin
			_endpoint_h = _tblink_rpc_pkg_init(
`ifdef VERILATOR
				0,
`else
				1,
`endif
				_time_precision
			);
		
			if (_endpoint_h == null) begin
				$display("Error: failure initializing tblink_rpc");
				$finish();
			end
		end
		
		return 1;
	endfunction
	int _init = _tblink_rpc_init();
	
	
	typedef class IInterfaceTypeBuilder;
	typedef class IInterfaceType;
	typedef class IInterfaceInst;
	typedef class IEndpoint;
	typedef class IInterfaceImpl;

	class IInterfaceInst;
		chandle			m_ifinst_h;
	endclass
	
	class IInterfaceType;
		chandle			m_iftype_h;
	endclass
	
	class IInvokeCall;
	endclass
	
	class IMethodType;
	endclass
	
	class IParamVal;
		chandle			m_obj;
	endclass
	
	class IParamValVector extends IParamVal;
	endclass
	
	class IInterfaceCall;
	endclass
	
	class IInterfaceImpl;
		virtual function void invoke_nb(IInterfaceCall call);
			$display("Error: invoke_nb not overridden");
			$finish();
		endfunction
		
		virtual task invoke(IInterfaceCall call);
			$display("Error: invoke not overridden");
			$finish();
		endtask
		
	endclass
	
	class IInterfaceTypeBuilder;
		chandle 		m_builder_h;
		
		function new();
			m_builder_h = null;
		endfunction
	endclass
	
	// _Verilator didn't have support for static class 
	// members when this code was created. Re-check later
	IEndpoint		_endpoint;

	typedef class tblink_rpc_thread;
	typedef class tblink_rpc_timed_cb;
	
	/**
	 * Class: IEndpoint
	 */
	class IEndpoint;
		chandle					m_endpoint_h;
		int unsigned			m_ifinst_id;
		IInterfaceImpl			m_ifinst_m[chandle];
`ifndef VERILATOR
		// Requests for new threads are queued here
		mailbox #(tblink_rpc_thread)   	m_thread_q = new();
		tblink_rpc_timed_cb				m_cb_m[chandle];
`endif
		
		function new();
			m_endpoint_h = null;
		endfunction
		
		function int build_complete();
			return _tblink_rpc_endpoint_build_complete(m_endpoint_h);
		endfunction
		
		function int connect_complete();
			return _tblink_rpc_endpoint_connect_complete(m_endpoint_h);
		endfunction
		
		function int shutdown();
			return _tblink_rpc_endpoint_shutdown(m_endpoint_h);
		endfunction
		
		function IInterfaceTypeBuilder newInterfaceTypeBuilder(string name);
			IInterfaceTypeBuilder ret = new();
			
			ret.m_builder_h = _tblink_rpc_endpoint_newInterfaceTypeBuilder(
						m_endpoint_h,
						name);
			return ret;
		endfunction
		
		function IInterfaceType defineInterfaceType(IInterfaceTypeBuilder builder);
			IInterfaceType ret = new();
			ret.m_iftype_h = _tblink_rpc_endpoint_defineInterfaceType(
					m_endpoint_h,
					builder.m_builder_h);
			
			return ret;
		endfunction
		
		function IInterfaceInst defineInterfaceInst(
			IInterfaceType			iftype,
			string					inst_name,
			IInterfaceImpl			ifinst_impl);
			IInterfaceInst ret = new();
			ret.m_ifinst_h = _tblink_rpc_endpoint_defineInterfaceInst(
				m_endpoint_h,
				iftype.m_iftype_h,
				inst_name);
			
			m_ifinst_m[ret.m_ifinst_h] = ifinst_impl;
	
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
			if (_endpoint == null) begin
				_endpoint = new();
				_endpoint.m_endpoint_h = _endpoint_h;
			end
			return _endpoint;
		endfunction

		// For environments with support for blocking tasks,
		// we need to run the main loop from within a task
		task run();
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
		endtask
		
		function void _invoke_nb(chandle call_h);
			$display("TODO: _invoke_nb");
		endfunction
	endclass
	
	/**
	 * tblink_rpc_run()
	 * 
	 * The run task must be called from a thread (eg initial) in the testbench
	 */
	task automatic tblink_rpc_run();
		IEndpoint ep;
		
		// Call init just in case it hasn't already been called
		void'(_tblink_rpc_init());
		
		ep = IEndpoint::inst();
		ep.run();
	endtask
		
	// IEndpoint functions
	import "DPI-C" context function int _tblink_rpc_endpoint_build_complete(chandle endpoint_h);
	import "DPI-C" context function int _tblink_rpc_endpoint_connect_complete(chandle endpoint_h);
	import "DPI-C" context function int _tblink_rpc_endpoint_shutdown(chandle endpoint_h);
	import "DPI-C" context function chandle _tblink_rpc_endpoint_newInterfaceTypeBuilder(
			chandle 	endpoint_h,
			string 		name);
	import "DPI-C" context function chandle _tblink_rpc_endpoint_defineInterfaceType(
			chandle		endpoint_h,
			chandle 	iftype_builder_h);
	
	import "DPI-C" context function chandle _tblink_rpc_endpoint_defineInterfaceInst(
			chandle		endpoint_h,
			chandle		iftype_h,
			string		inst_name);
			


	function automatic void _tblink_rpc_invoke_nb(chandle	call_h);
		IEndpoint ep = IEndpoint::inst();
		ep._invoke_nb(call_h);
	endfunction
	export "DPI-C" function _tblink_rpc_invoke_nb;
	
	
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

endpackage

