
/****************************************************************************
 * DpiTypeInt.svh
 ****************************************************************************/

  
/**
 * Class: DpiTypeInt
 * 
 * TODO: Add class documentation
 */
class DpiTypeInt extends ITypeInt;
	chandle			m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction;
		
	virtual function type_kind_e kind();
		return Int;
	endfunction

	virtual function int unsigned is_signed();
		return 0;
	endfunction
	
	virtual function int width();
		return -1;
	endfunction

endclass


