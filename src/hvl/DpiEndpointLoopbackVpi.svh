/****************************************************************************
 * DpiEndpointLoopbackVpi.svh
 ****************************************************************************/
 
reg prv_event = 0;

typedef class TbLink;
typedef class TbLinkThread;

  
/**
 * Class: DpiEndpointLoopbackVpi
 * 
 * TODO: Add class documentation
 */
class DpiEndpointLoopbackVpi extends DpiEndpoint;
	reg m_event = 0;
	
	class RunThread extends TbLinkThread;
		DpiEndpointLoopbackVpi m_ep;
	
		function new(DpiEndpointLoopbackVpi ep);
			m_ep = ep;
		endfunction
	
		virtual task run();
			m_ep.run();
		endtask
	endclass	

	function new(chandle hndl);
		TbLink tblink = TbLink::inst();
		RunThread t;
		super.new(hndl);
		$tblink_rpc_register_vpi_ev(prv_event);
		
		t = new(this);
		tblink.queue_thread(t);
	endfunction

	virtual task process_one_message_b(output int ret);
		$display("--> process_one_message_b");
		// In this implementation, need to use events to wait
		@(prv_event);
		ret = process_one_message();
		$display("<-- process_one_message_b");
	endtask
	
	task run();
		$display("%0t --> run()", $time);
		forever begin
			@(prv_event);
			$display("--> async: process_one_message()");
			process_one_message();
			$display("<-- async: process_one_message()");
		end
		$display("%0t <-- run()", $time);
	endtask
	
	static function DpiEndpointLoopbackVpi mk(chandle hndl=null);
		DpiEndpointLoopbackVpi ret;
		
		if (hndl == null) begin
			hndl = tblink_rpc_DpiEndpointLoopbackVpi_new();
		end
		
		ret = new(hndl);
		return ret;
	endfunction

endclass

import "DPI-C" context function chandle tblink_rpc_DpiEndpointLoopbackVpi_new();
