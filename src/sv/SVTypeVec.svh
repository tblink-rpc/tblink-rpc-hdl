
/****************************************************************************
 * SVTypeVec.svh
 ****************************************************************************/

  
/**
 * Class: SVTypeVec
 * 
 * TODO: Add class documentation
 */
class SVTypeVec extends ITypeVec;
	IType				m_elem_t;

	function new(IType elem_t);
		m_elem_t = elem_t;
	endfunction
	
	virtual function type_kind_e kind();
		return Vec;
	endfunction

	virtual function IType elem_t();
		return m_elem_t;
	endfunction

endclass


