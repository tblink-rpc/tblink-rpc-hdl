
/****************************************************************************
 * SVParamValInt.svh
 ****************************************************************************/

  
/**
 * Class: SVParamValInt
 * 
 * TODO: Add class documentation
 */
class SVParamValInt extends IParamValInt;
	longint			m_val;

	function new(longint val);
		m_val = val;
	endfunction
	
	virtual function longint val_s();
		return m_val;
	endfunction
	
	virtual function longint unsigned val_u();
		longint unsigned v = m_val;
		return v;
	endfunction	

	virtual function kind_e kind();
		return Int;
	endfunction
		
	virtual function IParamVal clone();
		SVParamValInt ret;
		longint val = m_val;
		ret = new(val);
		return ret;
	endfunction

endclass


