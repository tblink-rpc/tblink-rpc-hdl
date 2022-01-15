
/****************************************************************************
 * SVParamValMap.svh
 ****************************************************************************/

  
/**
 * Class: SVParamValMap
 * 
 * TODO: Add class documentation
 */
class SVParamValMap extends IParamValMap;
	IParamVal m_val_m[string];

	function new();
	endfunction
	
	virtual function bit hasKey(string key);
		if (m_val_m.exists(key) != 0) begin
			return 1;
		end else begin
			return 0;
		end
		return 0;
	endfunction
	
	virtual function IParamVal getVal(string key);
		if (m_val_m.exists(key) != 0) begin
			return m_val_m[key];
		end else begin
			return null;
		end
	endfunction
	
	virtual function void setVal(string key, IParamVal val);
		m_val_m[key] = val;
	endfunction

	virtual function kind_e kind();
		return Map;
	endfunction
		
	virtual function IParamVal clone();
		SVParamValMap ret = new();
		
		return ret;
	endfunction

endclass


