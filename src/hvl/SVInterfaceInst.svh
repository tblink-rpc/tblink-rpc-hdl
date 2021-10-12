
/****************************************************************************
 * SVInterfaceInst.svh
 ****************************************************************************/

typedef class SVEndpointLoopback;
  
/**
 * Class: SVInterfaceInst
 * 
 * TODO: Add class documentation
 */
class SVInterfaceInst extends IInterfaceInst;
	SVEndpointLoopback			m_ep;
	IInterfaceType				m_iftype;
	string						m_name;
	bit							m_is_mirror;
	IInterfaceImpl				m_impl;

	function new(
		SVEndpointLoopback	ep,
		IInterfaceType		iftype,
		string				name,
		bit					is_mirror,
		IInterfaceImpl		impl);
		m_ep = ep;
		m_iftype = iftype;
		m_name = name;
		m_is_mirror = is_mirror;
		m_impl = impl;
	endfunction

	virtual function void set_impl(IInterfaceImpl impl);
		m_impl = impl;
	endfunction
	
	virtual function IInterfaceImpl get_impl();
		return m_impl;
	endfunction
	
	virtual function string name();
		return m_name;
	endfunction
	
	virtual function IInterfaceType iftype();
		return m_iftype;
	endfunction
	
	virtual function bit is_mirror();
		return m_is_mirror;
	endfunction
	
	virtual function IParamVal invoke_nb(
		IMethodType					method,
		IParamValVec				params);
		return m_ep.invoke_nb(
				m_name,
				method,
				params);
	endfunction
	
	virtual task invoke_b(
		output IParamVal			retval,
		IMethodType					method,
		IParamValVec				params);
	endtask	
	
	virtual function IParamValBool mkValBool(
		int unsigned		val);
		return m_ep.mkValBool(val);
	endfunction
	
	virtual function IParamValInt mkValIntS(
		longint				val,
		int 				width);
		return m_ep.mkValIntS(val, width);
	endfunction
	
	virtual function IParamValInt mkValIntU(
		longint unsigned	val,
		int 				width);
		return m_ep.mkValIntU(val, width);
	endfunction
	
	virtual function IParamValMap mkValMap();
		return m_ep.mkValMap();
	endfunction
	
	virtual function IParamValStr mkValStr(
		string				val);
		return m_ep.mkValStr(val);
	endfunction
	
	virtual function IParamValVec mkValVec();
		return m_ep.mkValVec();
	endfunction

endclass


