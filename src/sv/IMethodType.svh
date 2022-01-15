
/****************************************************************************
 * IMethodType.svh
 ****************************************************************************/

  
/**
 * Class: IMethodType
 * 
 * TODO: Add class documentation
 */
class IMethodType;
		
	virtual function string name();
		return "";
	endfunction
		
	virtual function longint id();
		return -1;
	endfunction
	
	virtual function bit is_export();
		return 0;
	endfunction
	
	virtual function bit is_blocking();
		return 0;
	endfunction
	
endclass


