
/****************************************************************************
 * DpiParamValBool.svh
 ****************************************************************************/

  
/**
 * Class: DpiParamValBool
 * 
 * TODO: Add class documentation
 */
class DpiParamValBool extends IParamValBool;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction

	virtual function bit val();
		return (_tblink_rpc_iparam_val_bool_val(m_hndl) != 0);
	endfunction

	virtual function kind_e kind();
		return DpiParamVal::_kind(m_hndl);
	endfunction
	
	virtual function void dispose();
		DpiParamVal::do_dispose(m_hndl);
	endfunction

	virtual function IParamVal clone();
		return DpiParamVal::_clone(m_hndl);
	endfunction

endclass


