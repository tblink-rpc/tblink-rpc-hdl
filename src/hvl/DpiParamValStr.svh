/****************************************************************************
 * DpiParamValStr.svh
 ****************************************************************************/

  
/**
 * Class: DpiParamValStr
 * 
 * TODO: Add class documentation
 */
class DpiParamValStr extends IParamValStr;
	chandle			m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction
	
	virtual function kind_e kind();
		return DpiParamVal::_kind(m_hndl);
	endfunction
	
	virtual function string val();
		$display("TODO: DpiParamValStr::val");
		return "";
	endfunction

endclass


