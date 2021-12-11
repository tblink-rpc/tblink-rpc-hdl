
/****************************************************************************
 * TbLink.svh
 ****************************************************************************/
 
	typedef class TbLinkThread;
`ifndef VERILATOR
	typedef class TbLinkDeltaCb;
`endif

// Static class members are not yet supported in Verilator
typedef class TbLink;
TbLink			_tblink_inst;
  
/**
 * Class: TbLink
 * 
 * TODO: Add class documentation
 */
class TbLink;
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
	bit							m_dispatch_scheduled;
`endif
	bit							m_delta_cb_pending;
	int							m_last_ifinst_count;
	int							m_zero_count_repeat;

	function new();
		// Manually register known launch types
		begin
			SVLaunchTypeLoopback launch_t = new();
			m_sv_launch_type_m[launch_t.name()] = launch_t;
		end
		begin
			SVLaunchTypeNativeLoopbackVpi launch_t = new();
			m_sv_launch_type_m[launch_t.name()] = launch_t;
		end
		begin
			SVEndpointServicesFactory f = new();
			m_default_services_f = f;
		end
	endfunction
	
	function void setDefaultEp(IEndpoint ep);
		m_default_ep = ep;
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
				string errmsg;
				string args[$];
				
				tblink_rpc_get_plusargs("tblink.launcharg", args);
				
				foreach (args[i]) begin
					$display("add arg: %0s", args[i]);
					params.add_arg(args[i]);
				end

				// Ensure the launcher knows to register this as a default endpoint
				params.add_param("is_default", "1");

				m_default_ep = launch_t.launch(params, null, errmsg);
				
				if (m_default_ep == null) begin
					$display("TBLink Error: failed to launch %0s: %0s",
							launch, errmsg);
				end
		
//				$display("-- register_delta_cb");
//				register_delta_cb();
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

			$display("--> await_run_until_event");
			if (m_default_ep.await_run_until_event() == -1) begin
				$display("TbLink Error: failed while waiting for run-until-event");
				$finish(1);
			end
			$display("<-- await_run_until_event");
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
				m_default_ep_seqr = new(m_default_ep);
				m_default_ep_seqr.start();
			end
			
			fork
				dispatcher();
			join_none
		end
`else
		dispatch();
`endif
	endtask

`ifndef VERILATOR
	task dispatcher();
		TbLinkThread		t;
		
		forever begin
			m_dispatch_q.get(t);
			fork
				t.run();
			join_none
		end
	endtask
`else
	task dispatch();
		m_dispatch_scheduled = 0;
		while (m_dispatch_q != null) begin
			TbLinkThread t = m_dispatch_q;
			m_dispatch_q = m_dispatch_q.m_next;
			t.run();
		end
	endtask
`endif
	
	function void queue_thread(TbLinkThread t);
`ifndef VERILATOR
		void'(m_dispatch_q.try_put(t));
`else
		t.m_next = m_dispatch_q;
		m_dispatch_q = t;
		
		if (!m_dispatch_scheduled) begin
			tblink_rpc_register_dispatch_cb();
			m_dispatch_scheduled = 1;
		end
`endif
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
			_tblink_inst.auto_launch();
		end
		return _tblink_inst;
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

import "DPI-C" context function chandle vpi_iterate(int, chandle);

function automatic bit tblink_rpc_init();
	// Initialize DPI context for package
	int unsigned time_precision;
	TbLink tblink;
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

bit prv_tblink_init = tblink_rpc_init();

import "DPI-C" context function int _tblink_rpc_pkg_init(
		input int unsigned 		have_blocking_tasks,
		output int 				time_precision);
import "DPI-C" context function chandle tblink_rpc_findLaunchType(string id);
import "DPI-C" context function string tblink_rpc_libpath();

import "DPI-C" context function chandle tblink_rpc_TbLink_inst();
import "DPI-C" context function void tblink_rpc_TbLink_setDefaultEP(
	chandle		tblink,
	chandle		ep);
import "DPI-C" context function chandle tblink_rpc_TbLink_getDefaultEP(
	chandle		tblink);

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