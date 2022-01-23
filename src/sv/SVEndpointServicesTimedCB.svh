/****************************************************************************
 * SVEndpointServicesTimedCB.svh
 ****************************************************************************/

/**
 * Class: SVEndpointServicesTimedCB
 * 
 * TODO: Add class documentation
 */
class SVEndpointServicesTimedCB extends TbLinkThread;
	
	SVEndpointServices		m_services;
	longint unsigned		m_cb_time;
	longint					m_cb_id;
	bit						m_valid = 1;

	function new(
		SVEndpointServices	services,
		longint unsigned 	cb_time,
		longint				cb_id);
		m_services = services;
		m_cb_time = cb_time;
		m_cb_id = cb_id;
	endfunction

	virtual task run();
		TbLink tblink = TbLink::inst();
		$display("SVEndpointServicesTimedCB::run");
		$display("--> wait");
		case (tblink.m_time_precision)
			-15: #(m_cb_time*1fs);
			-12: #(m_cb_time*1ps);
			-9: #(m_cb_time*1ns);
			-6: #(m_cb_time*1us);
			-3: #(m_cb_time*1ms);
			0: #(m_cb_time*1s);
		endcase
		$display("<-- wait");

		m_services.notify_time_cb(m_cb_id);
	endtask

endclass


