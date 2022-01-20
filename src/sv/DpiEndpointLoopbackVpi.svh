/****************************************************************************
 * DpiEndpointLoopbackVpi.svh
 ****************************************************************************/
 
reg prv_event = 0;

typedef class TbLink;

typedef class DpiEndpointLoopbackVpi;

class _DpiEndpointLoopbackVpiRunThread extends TbLinkThread;
	DpiEndpointLoopbackVpi m_ep;
	
	function new(DpiEndpointLoopbackVpi ep);
		m_ep = ep;
	endfunction
	
	virtual task run();
		m_ep.run();
	endtask
endclass
  
/**
 * Class: DpiEndpointLoopbackVpi
 * 
 * TODO: Add class documentation
 */
class DpiEndpointLoopbackVpi extends DpiEndpoint;
	
	DpiEndpointLoopbackVpi			m_peer;

	function new(chandle hndl);
		m_hndl = hndl;
		begin
		TbLink tblink = TbLink::inst();
		_DpiEndpointLoopbackVpiRunThread t;
`ifndef VERILATOR
		$tblink_rpc_register_vpi_ev(prv_event);
		t = new(this);
		tblink.queue_thread(t);
`else
		$display("TODO: handle startup");
`endif
		end
	endfunction
	
	virtual function IEndpoint peer();
		if (m_peer == null) begin
			m_peer = new(tblink_rpc_IEndpointLoopback_peer(m_hndl));
		end
		
		return m_peer;
	endfunction

	virtual task process_one_message_b(output int ret);
		$display("--> process_one_message_b");
		// In this implementation, need to use events to wait
`ifndef VERILATOR
		@(prv_event);
`endif
		ret = process_one_message();
		$display("<-- process_one_message_b");
	endtask
	
	task run();
`ifndef VERILATOR
		$display("%0t --> run()", $time);
		forever begin
			@(prv_event);
			$display("--> async: process_one_message()");
			void'(process_one_message());
			$display("<-- async: process_one_message()");
		end
		$display("%0t <-- run()", $time);
`endif
	endtask
	
	static function DpiEndpointLoopbackVpi mk(chandle hndl=null);
		DpiEndpointLoopbackVpi ret;
		
		if (hndl == null) begin
			hndl = tblink_rpc_DpiEndpointLoopbackVpi_new();
		end
		
		ret = new(hndl);
		ret.m_this = ret;
		return ret;
	endfunction
	
endclass

import "DPI-C" context function chandle tblink_rpc_DpiEndpointLoopbackVpi_new();

import "DPI-C" context function chandle tblink_rpc_IEndpointLoopback_peer(chandle);
