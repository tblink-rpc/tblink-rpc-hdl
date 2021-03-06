/****************************************************************************
 * DpiEndpoint.svh
 ****************************************************************************/
 
`ifndef VERILATOR
	typedef class TbLinkThread;
	typedef class TbLinkTimedCb;
`endif

/**
 * Class: DpiEndpoint
 * 
 * TODO: Add class documentation
 */
class DpiEndpoint extends IEndpoint;
	chandle					m_hndl;
	DpiEndpoint				m_this;

	int unsigned			m_ifinst_id;
	IInterfaceImpl			m_ifimpl_m[chandle];
	chandle					m_ifinst_m[IInterfaceImpl];
	bit						m_started = 0;
	bit						m_running = 0;
	IEndpointServices		m_services;
	chandle					m_services_proxy;
	`ifndef VERILATOR
		// Requests for new threads are queued here
		mailbox #(TbLinkThread)   	m_thread_q = new();
		TbLinkTimedCb				m_cb_m[chandle];
	`endif

	function new();
	endfunction

	function void set_hndl(chandle h);
		m_hndl = h;
	endfunction

	function void set_this(DpiEndpoint t);
		m_this = t;
	endfunction
	
	virtual function IEndpointFlags_t getFlags();
		return IEndpointFlags_t'(tblink_rpc_IEndpoint_getFlags(m_hndl));
	endfunction
	
	virtual function void setFlag(IEndpointFlags_t f);
		tblink_rpc_IEndpoint_setFlag(m_hndl, int'(f));
	endfunction
	
	virtual function int init(
		IEndpointServices		ep_services);
		ep_services.init(m_this);
		m_services = ep_services;
		
		m_services_proxy = newDpiEndpointServicesProxy(ep_services);
		return tblink_rpc_IEndpoint_init(
				m_hndl,
				m_services_proxy);
	endfunction
	
	virtual function int is_init();
		return tblink_rpc_IEndpoint_is_init(m_hndl);
	endfunction

	virtual function int build_complete();
		return tblink_rpc_IEndpoint_build_complete(m_hndl);
	endfunction
	
	virtual function int is_build_complete();
		return tblink_rpc_IEndpoint_is_build_complete(m_hndl);
	endfunction
		
	virtual function int connect_complete();
		return tblink_rpc_IEndpoint_connect_complete(m_hndl);
	endfunction
	
	virtual function int is_connect_complete();
		return tblink_rpc_IEndpoint_is_connect_complete(m_hndl);
	endfunction
	
	virtual function comm_state_e comm_state();
		return comm_state_e'(tblink_rpc_IEndpoint_comm_state(m_hndl));
	endfunction
	
	virtual function void addListener(IEndpointListener l);
		connectDpiEndpointListenerProxy(m_hndl, l);
	endfunction
	
	virtual function void removeListener(IEndpointListener l);
		disconnectDpiEndpointListenerProxy(m_hndl, l);
	endfunction
	
	function int shutdown();
		return _tblink_rpc_endpoint_shutdown(m_hndl);
	endfunction
	
	virtual function void notify_callback(longint id);
		tblink_rpc_IEndpoint_notify_callback(m_hndl, id);
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
		
	virtual function IInterfaceType defineInterfaceType(
		IInterfaceTypeBuilder 		iftype_b,
		IInterfaceImplFactory		impl_f,
		IInterfaceImplFactory		impl_mirror_f);
		DpiInterfaceTypeBuilder builder_dpi;
		DpiInterfaceType ret;
		chandle iftype_h;
		chandle impl_f_proxy;
		chandle impl_mirror_f_proxy;
		
		if (impl_f != null) begin
			impl_f_proxy = newDpiInterfaceImplFactoryProxy(impl_f);
		end
		
		if (impl_mirror_f != null) begin
			impl_mirror_f_proxy = newDpiInterfaceImplFactoryProxy(impl_mirror_f);
		end
		
		$display("defineInterfaceType: %p %p", impl_f_proxy, impl_mirror_f_proxy);
		
		$cast(builder_dpi, iftype_b);
		iftype_h = tblink_rpc_IEndpoint_defineInterfaceType(
				m_hndl,
				builder_dpi.m_hndl,
				impl_f_proxy,
				impl_mirror_f_proxy);
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
		chandle ifimpl_h = newDpiInterfaceImplProxy(ifinst_impl);

		
		if (!$cast(iftype_dpi, iftype)) begin
			$display("TbLink Error: Interface type %0s doesn't match DPI endpoint", iftype.name());
			$finish();
			return null;
		end
		
		ifinst_h = _tblink_rpc_IEndpoint_defineInterfaceInst(
				m_hndl,
				iftype_dpi.m_hndl,
				inst_name,
				is_mirror,
				ifimpl_h);
		
		ifinst = new(ifinst_h);
		ifinst_impl.init(ifinst);
		
		return ifinst;
	endfunction
	
	virtual function IInterfaceInst createInterfaceObj(
		IInterfaceType			iftype,
		int unsigned			is_mirror,
		IInterfaceImpl			ifinst_impl);
		DpiInterfaceType		iftype_dpi;
		DpiInterfaceInst ifinst;
		chandle ifimpl_proxy_h = newDpiInterfaceImplProxy(ifinst_impl);
		chandle ifinst_h;
		
		if (!$cast(iftype_dpi, iftype)) begin
			$display("TbLink Error: iftype %0s is not a DPI object", iftype.name());
			$finish;
			return null;
		end
		
		ifinst_h = tblink_rpc_IEndpoint_createInterfaceObj(
				m_hndl,
				iftype_dpi.m_hndl,
				is_mirror,
				ifimpl_proxy_h);
		
		ifinst = new(ifinst_h);
		
		return ifinst;
	endfunction
	
	virtual function void destroyInterfaceObj(
		IInterfaceInst			ifinst);
		DpiInterfaceInst ifinst_dpi;
		
		if (!$cast(ifinst_dpi, ifinst)) begin
			$display("TbLink Error: ifinst %0s is not a DPI interface inst", ifinst.name());
			$finish;
			return;
		end
		
		tblink_rpc_IEndpoint_destroyInterfaceObj(
				m_hndl,
				ifinst_dpi.m_hndl);
	endfunction	
	
	virtual function int process_one_message();
		return tblink_rpc_IEndpoint_process_one_message(m_hndl);
	endfunction
	
	virtual task process_one_message_b(output int ret);
		// In the base case, we still perform a complete block
		ret = process_one_message();
	endtask
	
	virtual function void getInterfaceInsts(ref IInterfaceInst ifinsts[$]);
		int unsigned count = tblink_rpc_IEndpoint_getInterfaceInstCount(m_hndl);
		ifinsts = '{};
		for (int unsigned i=0; i<count; i++) begin
			chandle ifinst_h = tblink_rpc_IEndpoint_getInterfaceInstAt(m_hndl, i);
			DpiInterfaceInst ifinst = new(ifinst_h);
			ifinsts.push_back(ifinst);
		end
	endfunction

	`ifdef UNDEFINED
	`ifndef VERILATOR
		function void add_time_cb(
			chandle				cb_data,
			longint unsigned	delta);
			TbLinkTimedCb cb = new(cb_data, delta);
		
			void'(m_thread_q.try_put(cb));
			m_cb_m[cb_data] = cb;
		endfunction
		
		task notify_time_cb(TbLinkTimedCb cb);
			m_cb_m.delete(cb.m_cb_data);
			if (cb.m_valid) begin
				_tblink_rpc_notify_time_cb(cb.m_cb_data);
			end
		endtask
	`endif
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
			`ifdef VERILATOR
				// TODO: anything needed here?
			`else
				forever begin
					automatic TbLinkThread t;
					m_thread_q.get(t);
					
					fork
						t.run();
					join_none
				end				
			`endif
		end
	endtask
endclass

function DpiEndpoint mkDpiEndpoint(chandle hndl);
	DpiEndpoint ret;
	
	ret = new();
	ret.set_hndl(hndl);
	ret.set_this(ret);
	return ret;
endfunction

import "DPI-C" context function int tblink_rpc_IEndpoint_getFlags(
	chandle endpoint_h); 

import "DPI-C" context function void tblink_rpc_IEndpoint_setFlag(
	chandle endpoint_h, 
	int f);

import "DPI-C" context function int tblink_rpc_IEndpoint_init(
	chandle endpoint_h, 
	chandle services_h); 
import "DPI-C" context function int tblink_rpc_IEndpoint_is_init(
	chandle endpoint_h);
import "DPI-C" context function int tblink_rpc_IEndpoint_build_complete(chandle endpoint_h);
import "DPI-C" context function int tblink_rpc_IEndpoint_is_build_complete(chandle endpoint_h);
import "DPI-C" context function int tblink_rpc_IEndpoint_connect_complete(chandle endpoint_h);
import "DPI-C" context function int tblink_rpc_IEndpoint_is_connect_complete(chandle endpoint_h);
import "DPI-C" context function int tblink_rpc_IEndpoint_comm_state(chandle endpoint_h);
import "DPI-C" context function void tblink_rpc_IEndpoint_notify_callback(
	chandle		endpoint_h,
	longint		id);
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
	chandle 	iftype_builder_h,
	chandle		ifimpl_f_h,
	chandle		ifimpl_mirror_f_h);
	
import "DPI-C" context function int unsigned tblink_rpc_IEndpoint_getInterfaceInstCount(
	chandle		endpoint_h);
import "DPI-C" context function chandle tblink_rpc_IEndpoint_getInterfaceInstAt(
	chandle				endpoint_h,
	int unsigned		idx);
	
import "DPI-C" context function chandle _tblink_rpc_IEndpoint_defineInterfaceInst(
	chandle			endpoint_h,
	chandle			iftype_h,
	string			inst_name,
	int unsigned	is_mirror,
	chandle			ifimpl_h);

import "DPI-C" context function chandle tblink_rpc_IEndpoint_createInterfaceObj(
	chandle			endpoint_h,
	chandle			iftype_h,
	int unsigned	is_mirror,
	chandle			ifimpl_h);
	
import "DPI-C" context function void tblink_rpc_IEndpoint_destroyInterfaceObj(
	chandle			endpoint_h,
	chandle			ifinst_h);
	
import "DPI-C" context function int tblink_rpc_IEndpoint_process_one_message(
	chandle			endpoint_h);
	
	

