/****************************************************************************
 * DpiEndpointLoopbackDpi.svh
 ****************************************************************************/
 
typedef class TbLink;

/**
 * Class: DpiEndpointLoopbackDpi
 * 
 * TODO: Add class documentation
 */
class DpiEndpointLoopbackDpi extends DpiEndpoint;

	function new(chandle hndl);
		m_hndl = hndl;
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
	
	static function DpiEndpointLoopbackDpi mk(chandle hndl=null);
		DpiEndpointLoopbackDpi ret;
		
		if (hndl == null) begin
			hndl = tblink_rpc_DpiEndpointLoopback_new();
		end
		
		ret = new(hndl);
		ret.m_this = ret;
		return ret;
	endfunction
	
endclass

import "DPI-C" context function chandle tblink_rpc_DpiEndpointLoopback_new();
