/****************************************************************************
 * SVEndpointServicesProxy.svh
 ****************************************************************************/

  
/**
 * Class: SVEndpointServicesProxy
 * 
 * TODO: Add class documentation
 */
class SVEndpointServicesProxy extends IEndpointServices;
	
	IEndpointServices				m_core;
	bit								m_override_args = 0;
	string							m_args[$];

	function new(IEndpointServices core);
		m_core = core;
	endfunction

	virtual function void init(IEndpoint ep);
		m_core.init(ep);
	endfunction
		
	virtual function void args(ref string argv[$]);
		$display("SVEndpointServicesProxy::args %0d", m_override_args);
		argv = '{};
		if (m_override_args) begin
			foreach (m_args[i]) begin
				argv.push_back(m_args[i]);
			end
		end else begin
			m_core.args(argv);
		end
	endfunction
		
	virtual function int add_time_cb(
		longint unsigned			simtime,
		longint						callback_id);
		$display("SVEndpointServicesProxy::add_time_cb");
		return m_core.add_time_cb(simtime, callback_id);
	endfunction
		
	virtual function void cancel_callback(
		longint						callback_id);
		m_core.cancel_callback(callback_id);
	endfunction
		
	virtual function longint unsigned get_time();
		return m_core.get_time();
	endfunction
		
	virtual function int time_precision();
		return m_core.time_precision();
	endfunction

endclass


