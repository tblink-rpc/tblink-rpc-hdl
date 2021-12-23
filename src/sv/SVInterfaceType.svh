
/****************************************************************************
 * SVInterfaceType.svh
 ****************************************************************************/

  
/**
 * Class: SVInterfaceType
 * 
 * TODO: Add class documentation
 */
class SVInterfaceType extends IInterfaceType;
	string					m_name;
	method_l				m_methods;
	IMethodType				m_method_m[string];

	function new(string name);
		m_name = name;
	endfunction

	virtual function string name();
		return m_name;
	endfunction

	virtual function method_l methods();
		return m_methods;
	endfunction
	
	function void add_method(SVMethodType method_t);
		m_method_m[method_t.m_name] = method_t;
		m_methods.push_back(method_t);
	endfunction
	
	virtual function IMethodType findMethod(string name);
		if (m_method_m.exists(name) != 0) begin
			return m_method_m[name];
		end else begin
			return null;
		end
	endfunction

endclass


