/****************************************************************************
 * SVEndpointLoopback.svh
 ****************************************************************************/

  
/**
 * Class: SVEndpointLoopback
 * 
 * Implements a 'loopback' endpoint that connects 
 * HVL (TB) and HDL (design) components of the same
 * SystemVerilog simulation
 */
class SVEndpointLoopback extends IEndpoint;
	SVEndpointLoopback			m_peer_ep;
	bit							m_is_hdl;
	SVInterfaceType				m_iftype_m[string];

	function new(bit is_hdl);
		m_is_hdl = is_hdl;
	endfunction
	
	function IEndpoint peer_ep();
		return m_peer_ep;
	endfunction
	
	virtual function IInterfaceType findInterfaceType(string name);
		if (m_is_hdl) begin
			if (m_iftype_m.exists(name) != 0) begin
				return m_iftype_m[name];
			end else begin
				return null;
			end
		end else begin
			if (m_peer_ep.m_iftype_m.exists(name) != 0) begin
				return m_peer_ep.m_iftype_m[name];
			end else begin
				return null;
			end
		end
	endfunction

	virtual function IInterfaceTypeBuilder newInterfaceTypeBuilder(string name);
		SVInterfaceTypeBuilder ret = new(name);
		return ret;
	endfunction
	
	virtual function IInterfaceType defineInterfaceType(IInterfaceTypeBuilder iftype_b);
		SVInterfaceTypeBuilder iftype_b_sv;
		SVInterfaceType iftype;
		$cast(iftype_b_sv, iftype_b);
		
		iftype = iftype_b_sv.m_iftype;
		
		m_iftype_m[iftype.m_name] = iftype;
	
		return iftype;
	endfunction
	
	
	static function IEndpoint mk();
		SVEndpointLoopback hdl = new(1);
		SVEndpointLoopback hvl = new(0);
		
		hdl.m_peer_ep = hvl;
		hvl.m_peer_ep = hdl;
		
		return hdl;
	endfunction

endclass





