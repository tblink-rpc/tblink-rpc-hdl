
/****************************************************************************
 * IParamValInt.svh
 ****************************************************************************/

  
/**
 * Class: IParamValInt
 * 
 * TODO: Add class documentation
 */
class IParamValInt extends IParamVal;

		function longint unsigned val_u();
			return _tblink_rpc_iparam_val_int_val_u(m_hndl);
		endfunction
		
		function longint val_s();
		endfunction
		
endclass

