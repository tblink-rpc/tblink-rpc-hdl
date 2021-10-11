
/****************************************************************************
 * IParamValMap.svh
 ****************************************************************************/

  
/**
 * Class: IParamValMap
 * 
 * TODO: Add class documentation
 */
class IParamValMap extends IParamVal;
	
	virtual function bit hasKey(string key);
		return 0;
	endfunction
	
	virtual function IParamVal getVal(string key);
		return null;
	endfunction
	
	virtual function void setVal(string key, IParamVal val);
	endfunction

endclass


