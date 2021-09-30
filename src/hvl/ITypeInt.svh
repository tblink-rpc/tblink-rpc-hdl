
/****************************************************************************
 * ITypeInt.svh
 ****************************************************************************/

  
/**
 * Class: ITypeInt
 * 
 * TODO: Add class documentation
 */
class ITypeInt;

	virtual function int unsigned is_signed();
		return 0;
	endfunction
	
	virtual function int width();
		return -1;
	endfunction

endclass


