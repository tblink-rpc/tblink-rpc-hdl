/****************************************************************************
 * TbLinkTimedCb.svh
 ****************************************************************************/
 
typedef class TbLink;
  
/**
 * TbLinkTimedCb
 * 
 * Helper class to support timed callbacks
 */
class TbLinkTimedCb extends TbLinkThread;
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
		TbLink tblink = TbLink::inst();
		case (tblink.m_time_precision)
			-15: #(m_delta*1fs);
			-12: #(m_delta*1ps);
			-9: #(m_delta*1ns);
			-6: #(m_delta*1us);
			-3: #(m_delta*1ms);
			0: #(m_delta*1s);
		endcase
	
		tblink_rpc_notify_time_cb(m_cb_data);
	endtask
endclass	

import "DPI-C" context function void tblink_rpc_notify_time_cb(chandle cb_data);

