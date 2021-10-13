
/****************************************************************************
 * TbLink.svh
 ****************************************************************************/
 
`ifndef VERILATOR
	typedef class TbLinkThread;
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
	int							m_time_precision;
	ILaunchType					m_sv_launch_type_m[string];
`ifndef VERILATOR
	mailbox #(TbLinkThread)		m_dispatch_q = new();
	bit							m_dispatcher_running;
`endif
	bit							m_delta_cb_pending;
	int							m_last_ifinst_count;

	function new();
		
		// Manually register known launch types
		begin
			SVLaunchTypeLoopback launch_t = new();
			m_sv_launch_type_m["sv.loopback"] = launch_t;
		end
		
		auto_launch();

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

				m_default_ep = launch_t.launch(params, errmsg);
				
				if (m_default_ep == null) begin
					$display("TBLink Error: failed to launch %0s: %0s",
							launch, errmsg);
				end
			
				register_delta_cb();
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
			tblink_rpc_register_delta_cb();
		end
	endfunction
	
	function void delta_cb();
		IInterfaceInst ifinsts[$];
		m_delta_cb_pending = 0;
		
		m_default_ep.getInterfaceInsts(ifinsts);
		$display("delta_cb: %0d interfaces", ifinsts.size());
		if (ifinsts.size() != m_last_ifinst_count) begin
			$display("waiting another delta...");
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
		end
	endfunction
	
	function void start();
`ifndef VERILATOR
		if (m_dispatcher_running == 0) begin
			m_dispatcher_running = 1;
			fork
				dispatcher();
			join_none
		end
`endif
	endfunction

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
	
	function void queue_thread(TbLinkThread t);
		void'(m_dispatch_q.try_put(t));
	endfunction
`endif
	
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

function bit tblink_rpc_init();
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

function automatic void tblink_rpc_delta_cb();
	TbLink tblink = TbLink::inst();
	tblink.delta_cb();
endfunction
export "DPI-C" function tblink_rpc_delta_cb;
import "DPI-C" context function void tblink_rpc_register_delta_cb();

