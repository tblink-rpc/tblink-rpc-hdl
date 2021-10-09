
/****************************************************************************
 * SVType.svh
 ****************************************************************************/

  
/**
 * Class: SVType
 * 
 * TODO: Add class documentation
 */
class SVType extends IType;
	type_kind_e			m_kind;

	function new(type_kind_e kind);
		m_kind = kind;
	endfunction

	virtual function type_kind_e kind();
		return m_kind;
	endfunction

endclass


