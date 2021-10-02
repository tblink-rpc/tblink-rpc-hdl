/****************************************************************************
 * DpiEndpoint.svh
 ****************************************************************************/

/**
 * Class: DpiEndpoint
 * 
 * TODO: Add class documentation
 */
class DpiEndpoint extends IEndpoint;
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

	virtual function int build_complete();
		return tblink_rpc_IEndpoint_build_complete(m_hndl);
	endfunction
		
	virtual function int connect_complete();
		return tblink_rpc_IEndpoint_connect_complete(m_hndl);
	endfunction
	
	virtual function int start();
`ifndef VERILATOR
		_tblink_start_dispatcher();
`endif
		return _tblink_rpc_IEndpoint_start(m_hndl);
	endfunction
		
	function int shutdown();
		return _tblink_rpc_endpoint_shutdown(m_hndl);
	endfunction
	
	virtual function string last_error();
		return tblink_rpc_IEndpoint_last_error(m_hndl);
	endfunction
		
	function IInterfaceType findInterfaceType(string name);
		DpiInterfaceType ret;
		
		chandle if_h = tblink_rpc_IEndpoint_findInterfaceType(
				m_hndl,
				name);
		
		if (if_h != null) begin
			ret = new(if_h);
		end
		
		return ret;
	endfunction
		
	function IInterfaceTypeBuilder newInterfaceTypeBuilder(string name);
		DpiInterfaceTypeBuilder ret;
		chandle hndl = tblink_rpc_IEndpoint_newInterfaceTypeBuilder(m_hndl, name);
		
		ret = new(hndl);
		
		return ret;
	endfunction
		
	virtual function IInterfaceType defineInterfaceType(IInterfaceTypeBuilder iftype_b);
		DpiInterfaceTypeBuilder builder_dpi;
		DpiInterfaceType ret;
		chandle iftype_h;
		
		`DYN_CAST(builder_dpi, iftype_b);
		iftype_h = tblink_rpc_IEndpoint_defineInterfaceType(
				m_hndl,
				builder_dpi.m_hndl);
		ret = new(iftype_h);
		
		return ret;
	endfunction
		
		
	function IInterfaceInst defineInterfaceInst(
		IInterfaceType			iftype,
		string					inst_name,
		int unsigned			is_mirror,
		IInterfaceImpl			ifinst_impl);
		DpiInterfaceType iftype_dpi;
		DpiInterfaceInst ifinst;
		chandle ifinst_h;
		
		`DYN_CAST(iftype_dpi, iftype);
		
		ifinst_h = tblink_rpc_IEndpoint_defineInterfaceInst(
				m_hndl,
				iftype_dpi.m_hndl,
				inst_name,
				is_mirror,
				ifinst_impl);
		
		ifinst = new(ifinst_h);
		ifinst.set_impl(ifinst_impl);
		
		return ifinst;
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
`ifdef TODO
		chandle ifinst_h = tblink_rpc_InvokeInfo_ifinst(ii.m_hndl);
		IInterfaceImpl impl = m_ifimpl_m[ifinst_h];
		impl.m_ii = ii;
		
		m_next_ii = ii;
		
		impl.invoke_nb(ii);
`endif
	endfunction
	
	`ifdef UNDEFINED
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
	`endif /* UNDEFINED */

endclass


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
	
import "DPI-C" context function chandle tblink_rpc_IEndpoint_defineInterfaceType(
	chandle		endpoint_h,
	chandle 	iftype_builder_h);
	
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
	
	
