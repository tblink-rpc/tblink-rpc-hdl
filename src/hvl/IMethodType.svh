
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
	endfunction
		
	virtual function longint id();
	endfunction
	
	virtual function bit is_export();
	endfunction
	
	virtual function bit is_blocking();
	endfunction
	
endclass

