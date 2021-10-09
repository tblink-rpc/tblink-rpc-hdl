
/****************************************************************************
 * SVTypeInt.svh
 ****************************************************************************/

  
/**
 * Class: SVTypeInt
 * 
 * TODO: Add class documentation
 */
class SVTypeInt extends ITypeInt;
	int unsigned			m_is_signed;
	int						m_width;
	
	function new(int unsigned is_signed, int width);
		m_is_signed = is_signed;
		m_width = width;
	endfunction
	
	virtual function type_kind_e kind();
		return Int;
	endfunction

	virtual function int unsigned is_signed();
		return m_is_signed;
	endfunction
	
	virtual function int width();
		return m_width;
	endfunction

endclass


