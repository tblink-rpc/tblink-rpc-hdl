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
	SVInterfaceInst				m_ifinst_m[string];

	function new(bit is_hdl);
		$display("SVEndpointLoopback: is_hdl=%0d", is_hdl);
		m_is_hdl = is_hdl;
	endfunction
	
	function IEndpoint peer_ep();
		return m_peer_ep;
	endfunction
	
	virtual function int build_complete();
		return 0;
	endfunction
	
	virtual function int is_build_complete();
		return 0;
	endfunction
	
	virtual function int connect_complete();
		return 0;
	endfunction
	
	virtual function int is_connect_complete();
		return 0;
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
	
	virtual function IInterfaceInst defineInterfaceInst(
		IInterfaceType			iftype,
		string					inst_name,
		int unsigned			is_mirror,
		IInterfaceImpl			ifinst_impl);
		SVEndpointLoopback ep = m_peer_ep.m_peer_ep;
		SVInterfaceInst ifinst = new(
				ep, iftype, inst_name, is_mirror, ifinst_impl);
		$display("defineInterfaceInst: %0s", inst_name);
		m_ifinst_m[inst_name] = ifinst;
	
		return ifinst;
	endfunction
	
	function IParamVal invoke_nb(
		string			ifinst_name,
		IMethodType		method,
		IParamValVec	params);
		SVInterfaceInst ifinst;
		IParamVal retval;
		
		$display("invoke_nb: ifinst_name=%0s", ifinst_name);
		
		ifinst = m_peer_ep.m_ifinst_m[ifinst_name];
		
		retval = ifinst.m_impl.invoke_nb(
				ifinst, 
				method, 
				params);

		return retval;
	endfunction
	
	static function IEndpoint mk();
		SVEndpointLoopback hdl = new(1);
		SVEndpointLoopback hvl = new(0);
		
		hdl.m_peer_ep = hvl;
		hvl.m_peer_ep = hdl;
		
		return hdl;
	endfunction

endclass





