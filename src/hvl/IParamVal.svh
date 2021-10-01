
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
	endfunction
		
	virtual function IParamVal clone();
	endfunction
		
endclass

