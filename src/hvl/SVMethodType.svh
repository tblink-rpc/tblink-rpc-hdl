
/****************************************************************************
 * SVMethodType.svh
 ****************************************************************************/

  
/**
 * Class: SVMethodType
 * 
 * TODO: Add class documentation
 */
class SVMethodType extends IMethodType;
	string				m_name;
	longint				m_id;
	IType				m_rtype;
	bit					m_is_export;
	bit					m_is_blocking;
	string				m_param_names[$];
	IType				m_param_types[$];

	function new(
		string			name,
		longint			id,
		IType			rtype,
		bit				is_export,
		bit				is_blocking);
		m_name = name;
		m_id = id;
		m_rtype = rtype;
		m_is_export = is_export;
		m_is_blocking = is_blocking;
	endfunction
	
	virtual function string name();
		return m_name;
	endfunction
		
	virtual function longint id();
		return m_id;
	endfunction
	
	virtual function bit is_export();
		return m_is_export;
	endfunction
	
	virtual function bit is_blocking();
		return m_is_blocking;
	endfunction	
	
	virtual function void add_param(
		string			name,
		IType			ptype);
		m_param_names.push_back(name);
		m_param_types.push_back(ptype);
	endfunction

endclass


