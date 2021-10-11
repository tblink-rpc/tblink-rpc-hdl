
/****************************************************************************
 * SVParamValBool.svh
 ****************************************************************************/

  
/**
 * Class: SVParamValBool
 * 
 * TODO: Add class documentation
 */
class SVParamValBool extends IParamValBool;
	bit				m_val;

	function new(bit val);
		m_val = val;
	endfunction

	virtual function IParamVal clone();
		SVParamValBool ret;
		ret = new(m_val);
		return ret;
	endfunction	

endclass


