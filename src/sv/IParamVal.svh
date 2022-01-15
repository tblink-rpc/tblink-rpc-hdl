
/****************************************************************************
 * IParamVal.svh
 ****************************************************************************/

  
/**
 * Class: IParamVal
 * 
 * TODO: Add class documentation
 */
class IParamVal;
			
	typedef enum {
		Bool=0,
		Int,
		Map,
		Str,
		Vec
	} kind_e;
		
	virtual function kind_e kind();
		return Bool;
	endfunction
	
	virtual function void dispose();
	endfunction
		
	virtual function IParamVal clone();
		return null;
	endfunction
		
endclass

