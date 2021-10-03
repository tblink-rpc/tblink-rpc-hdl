
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
	endfunction
	
	virtual function IParamVal getVal(string key);
	endfunction
	
	virtual function setVal(string key, IParamVal val);
	endfunction

endclass


