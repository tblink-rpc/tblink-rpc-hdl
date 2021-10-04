
/****************************************************************************
 * SVEndpointLoopback.svh
 ****************************************************************************/

  
/**
 * Class: SVEndpointLoopback
 * 
 * TODO: Add class documentation
 */
class SVEndpointLoopback extends IEndpoint;
	SVEndpointLoopback			m_peer_ep;

	function new();
	endfunction
	
	function IEndpoint peer_ep();
		return m_peer_ep;
	endfunction
	
	static function IEndpoint mk();
		SVEndpointLoopback hdl = new();
		SVEndpointLoopback hvl = new();
		
		hdl.m_peer_ep = hvl;
		hvl.m_peer_ep = hdl;
		
		return hdl;
	endfunction

endclass





