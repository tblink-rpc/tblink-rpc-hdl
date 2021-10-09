
/****************************************************************************
 * SVTypeMap.svh
 ****************************************************************************/

  
/**
 * Class: SVTypeMap
 * 
 * TODO: Add class documentation
 */
class SVTypeMap extends ITypeMap;
	IType				m_key_t;
	IType				m_elem_t;

	function new(IType key_t, IType elem_t);
		m_key_t = key_t;
		m_elem_t = elem_t;
	endfunction

	virtual function type_kind_e kind();
		return Map;
	endfunction

endclass


