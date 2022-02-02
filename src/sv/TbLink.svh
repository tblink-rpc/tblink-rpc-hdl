/****************************************************************************
 * TbLink.svh
 ****************************************************************************/
 
`ifndef VERILATOR
typedef class TbLinkDeltaCb;
`endif

// Static class members are not yet supported in Verilator
typedef class TbLink;
TbLink			_tblink_inst;

bit prv_tblink_init = tblink_rpc_init();
  
/**
 * Class: TbLink
 * 
 * TODO: Add class documentation
 */
class TbLink extends ITbLinkListener;
	IEndpoint					m_default_ep;
	IEndpointServicesFactory	m_default_services_f;
	SVEndpointSequencer			m_default_ep_seqr;
	int							m_time_precision;
	ILaunchType					m_sv_launch_type_m[string];
`ifndef VERILATOR
	mailbox #(TbLinkThread)		m_dispatch_q = new();
	bit							m_dispatcher_running;
`else
	TbLinkThread				m_dispatch_q;
	bit							m_dispatch_started;
	bit							m_dispatch_scheduled;
`endif
	bit							m_delta_cb_pending;
	int							m_last_ifinst_count;
	int							m_zero_count_repeat;
	chandle						m_tblink_core;
	IEndpoint					m_endpoints[$];
	IInterfaceTypeRgy			m_iftype_rgy[$];
	IInterfaceTypeRgy			m_iftype_rgy_m[string];

	function new();

		
		// Manually register known launch types
		begin
			SVLaunchTypeLoopback launch_t = new();
			m_sv_launch_type_m[launch_t.name()] = launch_t;
		end
`ifndef VERILATOR
		begin
			SVLaunchTypeNativeLoopbackVpi launch_t = new();
			m_sv_launch_type_m[launch_t.name()] = launch_t;
		end
`else
		begin
			SVLaunchTypeNativeLoopbackDpi launch_t = new();
			m_sv_launch_type_m[launch_t.name()] = launch_t;
		end
`endif
		begin
			SVLaunchTypeConnectLoopback launch_t = new();
			m_sv_launch_type_m[launch_t.name()] = launch_t;
		end
		begin
			SVEndpointServicesFactory f = new();
			m_default_services_f = f;
		end
		
	endfunction
	
	function chandle tblink_core();
		if (m_tblink_core == null) begin
			TbLink tblink = TbLink::inst();
			chandle proxy = newDpiTbLinkListenerProxy(tblink);
			m_tblink_core = tblink_rpc_TbLink_inst();
			tblink_rpc_TbLink_addListener(m_tblink_core, proxy);
		end
		return m_tblink_core;
	endfunction
	
	function void setTimePrecision(int p);
		m_time_precision = p;
	endfunction
	
	function void setDefaultEp(IEndpoint ep);
		m_default_ep = ep;
	endfunction
	
	function void addIfTypeRgy(IInterfaceTypeRgy f);
		chandle tblink_h = tblink_core();
		$display("addIfFactory: %0s", f.name());
		m_iftype_rgy.push_back(f);
		m_iftype_rgy_m[f.name()] = f;
		
		foreach (m_endpoints[i]) begin
			if (!(m_endpoints[i].getFlags() & IEndpointFlags::LoopbackSec)) begin
				$display("defineType");
				void'(f.defineType(m_endpoints[i]));
			end
		end
		for (int i=0; i<tblink_rpc_TbLink_getEndpoints_size(tblink_h); i++) begin
			DpiEndpoint ep = mkDpiEndpoint(
					tblink_rpc_TbLink_getEndpoints_at(tblink_h, i));
			if (!(ep.getFlags() & IEndpointFlags::LoopbackSec)) begin
				void'(f.defineType(ep));
			end
		end
	endfunction
	
	function void addEndpoint(IEndpoint ep);
		DpiEndpoint dpi_ep;
		
		m_endpoints.push_back(ep);
		
		$display("addEndpoint: flags='h%08h", ep.getFlags());
		// Register known types with the endpoint 
		// as long as it's claimed
		if (!(ep.getFlags() & IEndpointFlags::LoopbackSec)) begin
			foreach (m_iftype_rgy[i]) begin
				void'(m_iftype_rgy[i].defineType(ep));
			end
		end
		
		if ($cast(dpi_ep, ep)) begin
			tblink_rpc_TbLink_addEndpoint(
					tblink_core(),
					dpi_ep.m_hndl);
		end
		
	endfunction
	
	function void removeEndpoint(IEndpoint ep);
		DpiEndpoint dpi_ep;
		
		if ($cast(dpi_ep, ep)) begin
		end
	endfunction
	
	function IEndpoint getDefaultEp();
		return m_default_ep;
	endfunction
	
	function IEndpointServicesFactory getDefaultServicesFactory();
		return m_default_services_f;
	endfunction
	
	function void setDefaultServicesFactory(IEndpointServicesFactory f);
		m_default_services_f = f;
	endfunction
	
	function int getTimePrecision();
		return m_time_precision;
	endfunction
	
	virtual function void notify(ITbLinkEvent ev);
		$display("notify");
		if (ev.kind() == TbLinkEventKind::AddEndpoint) begin
			chandle tblink_h = tblink_core();
			DpiEndpoint last_ep = mkDpiEndpoint(
					tblink_rpc_TbLink_getEndpoints_at(
						tblink_h,
						tblink_rpc_TbLink_getEndpoints_size(tblink_h)-1));
			if (!(last_ep.getFlags() & IEndpointFlags::LoopbackSec)) begin
				register_types(last_ep);
			end
		end
	endfunction
	
	function void auto_launch();
		string launch;
		
		/**
		 * Determine whether an endpoint must be auto-launched
		 */
		if ($value$plusargs("tblink.launch=%s", launch)) begin
			ILaunchType launch_t;
			
			launch_t = findLaunchType(launch);
			
			if (launch_t == null) begin
				$display("Error: launch type %0s doesn't exist", launch);
				$finish(1);
			end else begin
				ILaunchParams params = launch_t.newLaunchParams();
				chandle params_proxy = newLaunchParamsProxy(params);
				string errmsg;
				string args[$];

				tblink_rpc_ParseLaunchPlusargs(params_proxy, errmsg);
				delLaunchParamsProxy(params_proxy);
				
				if (errmsg != "") begin
					$display("TbLink Error: %s while parsing launch arguments", errmsg);
					$finish();
					return;
				end

				/*
				tblink_rpc_get_plusargs("tblink.launcharg", args);
				
				foreach (args[i]) begin
					$display("add arg: %0s", args[i]);
					params.add_arg(args[i]);
				end
				 */

				// Ensure the launcher knows to register this as a default endpoint
				params.add_param(string'("is_default"), string'("1"));

				m_default_ep = launch_t.launch(params, null, errmsg);
				
				if (m_default_ep == null) begin
					$display("TBLink Error: failed to launch %0s: %0s",
							launch, errmsg);
					$finish();
					return;
				end
			end
		end else begin
			$display("TbLink Note: no default endpoint launched");
		end		
	endfunction

	/**
	 * These are used for managing start-up for auto-launched
	 * endpoints.
	 */
	function void register_delta_cb();
		if (!m_delta_cb_pending) begin
			m_delta_cb_pending = 1;
`ifdef VERILATOR
			tblink_rpc_register_delta_cb();
`else
			begin
				TbLinkDeltaCb #(TbLink) cb = new(this);
				queue_thread(cb);
			end
`endif
		end
	endfunction
	
	function void delta_cb();
		IInterfaceInst ifinsts[$];
		m_delta_cb_pending = 0;
		
		m_default_ep.getInterfaceInsts(ifinsts);
		$display("delta_cb: %0d interfaces", ifinsts.size());
		if ((ifinsts.size() != m_last_ifinst_count) || (ifinsts.size() == 0 && m_zero_count_repeat < 4)) begin
			$display("waiting another delta...");
			m_zero_count_repeat++;
			m_last_ifinst_count = ifinsts.size();
			register_delta_cb();
		end else begin
			/**
			 * Once we're sure all BFMs have registered,
			 * cycle through the build/connect process
			 */
			$display("done...");
			/*
			if (m_default_ep.init() == -1) begin
				$display("build-complete failed");
				$finish();
				return;
			end
			 */
			if (m_default_ep.build_complete() == -1) begin
				$display("build-complete failed");
				$finish();
				return;
			end
			
			if (m_default_ep.connect_complete() == -1) begin
				$display("connect-complete failed");
				$finish();
				return;
			end

			/* TODO:
			$display("--> await_run_until_event");
			if (m_default_ep.await_run_until_event() == -1) begin
				$display("TbLink Error: failed while waiting for run-until-event");
				$finish(1);
			end
			$display("<-- await_run_until_event");
			 */
		end
	endfunction

`ifndef VERILATOR
	task start_default_ep();

		
	endtask
`endif
	
	task start();
		$display("start");
`ifndef VERILATOR
		if (m_dispatcher_running == 0) begin
			m_dispatcher_running = 1;
			
			if (m_default_ep != null) begin
				m_default_ep_seqr = mkSVEndpointSequencer(m_default_ep);
				m_default_ep_seqr.start();
			end
			
			fork
				dispatcher();
			join_none
		end
`else
		if (m_dispatch_started == 0) begin
			m_dispatch_started = 1;
			
			if (m_default_ep != null) begin
				m_default_ep_seqr = mkSVEndpointSequencer(m_default_ep);
				m_default_ep_seqr.start();
			end
		end
		dispatch();
`endif
	endtask

`ifdef VERILATOR
	function TbLinkThread next_thread();
		TbLinkThread t = m_dispatch_q;
		m_dispatch_q = t.next();
		return t;
	endfunction
`endif

`ifndef VERILATOR
	task dispatcher();
		
		forever begin
			automatic TbLinkThread	t;
			m_dispatch_q.get(t);
			
			fork
				t.run();
			join_none
		end
	endtask
`else
	task dispatch();
		TbLinkThread q = m_dispatch_q;
		m_dispatch_q = null;
		m_dispatch_scheduled = 0;
		$display("--> dispatch");
		while (q != null) begin
			TbLinkThread t = q;
			q = t.next();
			t.set_next(null);
//			$display("t=%p m_dispatch_q=%p", t, q);
			$display("--> run");
			t.run();
			$display("<-- run");
		end
		$display("<-- dispatch");
	endtask
`endif
	
	function void queue_thread(TbLinkThread t);
		$display("--> queue_thread");
`ifndef VERILATOR
		void'(m_dispatch_q.try_put(t));
`else
		if (t.next() != null) begin
			$display("Internal Error: thread already scheduled");
			return;
		end
		t.set_next(m_dispatch_q);
		m_dispatch_q = t;
		
		if (!m_dispatch_scheduled) begin
			tblink_rpc_register_dispatch_cb();
			m_dispatch_scheduled = 1;
		end
`endif
		$display("<-- queue_thread");
	endfunction
	
	function IEndpoint get_default_ep();
		if (m_default_ep == null) begin
			// TODO: query native layer to determine if a default
			// endpoint has been created there
			
			$display("Need to build new");
		end
		return m_default_ep;
	endfunction
	
	function ILaunchType findLaunchType(string id);
		ILaunchType ret;
		
		if (m_sv_launch_type_m.exists(id) != 0) begin
			ret = m_sv_launch_type_m[id];
		end else begin
			chandle launch_type_h = tblink_rpc_findLaunchType(id);
		
			if (launch_type_h != null) begin
				DpiLaunchType ret_dpi;
				ret_dpi = new(launch_type_h);
				ret = ret_dpi;
			end
		end
		
		return ret;
	endfunction
	
	function void registerLaunchType(ILaunchType lt);
		$display("registerLaunchType: %0s", lt.name());
		m_sv_launch_type_m[lt.name()] = lt;
	endfunction
	
	static function TbLink inst();
		if (_tblink_inst == null) begin
			_tblink_inst = new();
			void'(_tblink_inst.tblink_core());
			_tblink_inst.auto_launch();
		end
		return _tblink_inst;
	endfunction
	
	function void register_types(IEndpoint ep);
		foreach (m_iftype_rgy[i]) begin
			void'(m_iftype_rgy[i].defineType(ep));
		end
	endfunction

endclass

`ifdef VERILATOR
	// For simplicity, we still provide the export
	// even though Verilator uses a different mechanism
	function void tblink_rpc_add_time_cb(
		chandle				cb_data,
		longint unsigned	delta);
		$display("Error: tblink_register_timed_callback called from Verilator");
		$finish;
	endfunction
	export "DPI-C" function tblink_rpc_add_time_cb;	
		
	function void tblink_rpc_notify_time_cb(chandle	cb_data);
		$display("Error: tblink_rpc_notify_time_callback called");
		$finish;
	endfunction
`else
	function automatic void tblink_rpc_add_time_cb(
		chandle				cb_data,
		longint unsigned	delta);
		TbLinkTimedCb t = new(cb_data, delta);
		TbLink tblink = TbLink::inst();
		tblink.queue_thread(t);
	endfunction
	export "DPI-C" function tblink_rpc_add_time_cb;	
	
`endif /* !VERILATOR */

function automatic bit tblink_rpc_init();
	// Initialize DPI context for package
	int unsigned time_precision;
	TbLink tblink;
	$display("tblink_rpc_init");
	if (_tblink_rpc_pkg_init(
				`ifdef VERILATOR
					0,
				`else
					1,
				`endif
			time_precision) == 0) begin
		$display("Error: failed to initialize tblink package");
	end
	
	tblink = TbLink::inst();
	tblink.m_time_precision = time_precision;
	
	return 1;
endfunction

import "DPI-C" context function int _tblink_rpc_pkg_init(
		input int unsigned 		have_blocking_tasks,
		output int 				time_precision);
import "DPI-C" context function chandle tblink_rpc_findLaunchType(string id);
import "DPI-C" context function string tblink_rpc_libpath();

import "DPI-C" context function void tblink_rpc_TbLink_setDefaultEP(
	chandle		tblink,
	chandle		ep);
import "DPI-C" context function chandle tblink_rpc_TbLink_getDefaultEP(
	chandle		tblink);
import "DPI-C" context function void tblink_rpc_TbLink_addListener(
	chandle		tblink,
	chandle		listener);
import "DPI-C" context function void tblink_rpc_TbLink_removeListener(
	chandle		tblink,
	chandle		listener);
	
import "DPI-C" context function void tblink_rpc_TbLink_addEndpoint(
	chandle		tblink,
	chandle		ep);
import "DPI-C" context function int unsigned tblink_rpc_TbLink_getEndpoints_size(
	chandle			tblink);
import "DPI-C" context function chandle tblink_rpc_TbLink_getEndpoints_at(
	chandle			tblink,
	int unsigned	idx);
	
import "DPI-C" context function chandle tblink_rpc_TbLink_inst();
	
import "DPI-C" context function void tblink_rpc_ParseLaunchPlusargs(
	chandle			params_proxy,
	output string	errmsg);
	

`ifdef VERILATOR
/**
 * Time-based callbacks and running of tasks are implemented
 * via VPI in Verilator. The functions implement the interface.
 */
function automatic void tblink_rpc_delta_cb();
	TbLink tblink = TbLink::inst();
	tblink.delta_cb();
endfunction
export "DPI-C" function tblink_rpc_delta_cb;
import "DPI-C" context function void tblink_rpc_register_delta_cb();

import "DPI-C" context function void tblink_rpc_register_dispatch_cb();

task automatic tblink_rpc_dispatch_cb();
	TbLink tblink = TbLink::inst();
	tblink.dispatch();
endtask
export "DPI-C" task tblink_rpc_dispatch_cb;

`endif /* VERILATOR */
