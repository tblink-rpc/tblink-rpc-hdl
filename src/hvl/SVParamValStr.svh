
/****************************************************************************
 * SVParamValStr.svh
 ****************************************************************************/

  
/**
 * Class: SVParamValStr
 * 
 * TODO: Add class documentation
 */
class SVParamValStr extends IParamValStr;
	string			m_val;

	function new(string val);
		m_val = val;
	endfunction

	virtual function kind_e kind();
		return Str;
	endfunction
		
	virtual function IParamVal clone();
		SVParamValStr rv;
		string val = m_val;
		rv = new(val);
		return rv;
	endfunction
	
	virtual function string val();
		return m_val;
	endfunction

endclass


