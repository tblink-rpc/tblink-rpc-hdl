
/****************************************************************************
 * IParamValBool.svh
 ****************************************************************************/

  
/**
 * Class: IParamValBool
 * 
 * TODO: Add class documentation
 */
class IParamValBool extends IParamVal;
		
	function bit val();
		return (_tblink_rpc_iparam_val_bool_val(m_hndl) != 0);
	endfunction
		
	function IParamValBool clone();
		IParamValBool ret = new();
		ret.m_hndl = _tblink_rpc_iparam_val_clone(m_hndl);
		return ret;
	endfunction
		
endclass


