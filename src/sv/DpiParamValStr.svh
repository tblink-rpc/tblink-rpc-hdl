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
		return tblink_rpc_IParamValStr_val(m_hndl);
	endfunction
	
	virtual function void dispose();
		DpiParamVal::do_dispose(m_hndl);
	endfunction
	
	virtual function IParamVal clone();
		return DpiParamVal::_clone(m_hndl);
	endfunction

endclass

import "DPI-C" context function string tblink_rpc_IParamValStr_val(
	chandle 				hndl);


