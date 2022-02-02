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
	IEndpointServices			m_services;
	SVInterfaceType				m_iftype_m[string];
	SVInterfaceInst				m_ifinst_m[string];
	SVInterfaceInst				m_ifinsts[$];
	IEndpointListener			m_listeners[$];
	IEndpoint::comm_state_e		m_comm_state = IEndpoint::Waiting;
	IEndpoint::comm_mode_e		m_comm_mode = IEndpoint::Automatic;
	IEndpointFlags_t			m_flags;

	function new(bit is_hdl);
		$display("SVEndpointLoopback: is_hdl=%0d", is_hdl);
		m_is_hdl = is_hdl;
		m_comm_state = IEndpoint::Released;
		m_comm_mode = IEndpoint::Explicit;
		if (is_hdl) begin
			m_flags = IEndpointFlags_t'(m_flags | IEndpointFlags::Claimed);
		end
	endfunction
	
	virtual function IEndpointFlags_t getFlags();
		return m_flags;
	endfunction
	
	virtual function void setFlag(IEndpointFlags_t f);
		m_flags = IEndpointFlags_t'(m_flags | f);
	endfunction
	
	function IEndpoint peer_ep();
		return m_peer_ep;
	endfunction
	
	virtual function int init(IEndpointServices ep_services);
		m_services = ep_services;
	endfunction
	
	virtual function int is_init();
		return 1;
	endfunction
	
	virtual function int build_complete();
		return 1;
	endfunction
	
	virtual function int is_build_complete();
		return 1;
	endfunction
	
	virtual function int connect_complete();
		return 1;
	endfunction
	
	virtual function int is_connect_complete();
		return 1;
	endfunction	
	
	virtual function void addListener(IEndpointListener l);
		m_listeners.push_back(l);
	endfunction
	
	virtual function void removeListener(IEndpointListener l);
		for (int i=0; i<m_listeners.size(); i++) begin
			if (m_listeners[i] == l) begin
				m_listeners.delete(i);
				break;
			end
		end
	endfunction
	
	virtual function comm_state_e comm_state();
		return m_comm_state;
	endfunction
	
	virtual function comm_mode_e comm_mode();
		return m_comm_mode;
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
	
	virtual function IInterfaceType defineInterfaceType(
		IInterfaceTypeBuilder iftype_b,
		IInterfaceImplFactory		impl_f,
		IInterfaceImplFactory		impl_mirror_f);
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
		SVEndpointLoopback ep;
		SVInterfaceInst ifinst;
		ep = m_peer_ep.m_peer_ep;
		ifinst = new(
			ep, 
			iftype, 
			inst_name, 
			(is_mirror != 0), 
			ifinst_impl);
		m_ifinst_m[inst_name] = ifinst;
		m_ifinsts.push_back(ifinst);
		ifinst_impl.init(ifinst);
	
		return ifinst;
	endfunction
	
	virtual function int process_one_message();
		return 0;
	endfunction
	
	virtual function void getInterfaceInsts(ref IInterfaceInst ifinsts[$]);
		$display("getInterfaceInsts: %0d", m_ifinsts.size());
		ifinsts = '{};
		foreach (m_ifinsts[i]) begin
			ifinsts.push_back(m_ifinsts[i]);
		end
	endfunction
	
	virtual function IParamValBool mkValBool(
		int unsigned		val);
		SVParamValBool rv = new((val!=0));
		return rv;
	endfunction
	
	virtual function IParamValInt mkValIntS(
		longint				val,
		int 				width);
		SVParamValInt rv = new(val);
		return rv;
	endfunction
	
	virtual function IParamValInt mkValIntU(
		longint unsigned	val,
		int 				width);
		SVParamValInt rv = new(val);
		return rv;
	endfunction
	
	virtual function IParamValMap mkValMap();
		SVParamValMap rv = new();
		return rv;
	endfunction
	
	virtual function IParamValStr mkValStr(
		string				val);
		SVParamValStr rv = new(val);
		return rv;
	endfunction
	
	virtual function IParamValVec mkValVec();
		SVParamValVec rv = new();
		return rv;
	endfunction
	
	function SVInterfaceInst find_ifinst(string name);
		if (m_ifinst_m.exists(name) != 0) begin
			return m_ifinst_m[name];
		end else begin
			return null;
		end
	endfunction
	
	function IParamVal invoke_nb(
		string			ifinst_name,
		IMethodType		method,
		IParamValVec	params);
		SVInterfaceInst ifinst;
		IParamVal retval;
		
		ifinst = m_peer_ep.find_ifinst(ifinst_name);
		
		retval = ifinst.m_impl.invoke_nb(
				ifinst, 
				method, 
				params);

		return retval;
	endfunction
	
	virtual task invoke_b(
		input string			ifinst_name,
		output IParamVal		retval,
		input  IMethodType		method,
		input  IParamValVec		params);
		SVInterfaceInst ifinst;
		
		ifinst = m_peer_ep.find_ifinst(ifinst_name);
		
		ifinst.m_impl.invoke_b(
				retval,
				ifinst, 
				method, 
				params);
	endtask
	
	static function IEndpoint mk();
		SVEndpointLoopback hdl = new(1);
		SVEndpointLoopback hvl = new(0);
		
		hdl.m_peer_ep = hvl;
		hvl.m_peer_ep = hdl;
		
		return hdl;
	endfunction

endclass





