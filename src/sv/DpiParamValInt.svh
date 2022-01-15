
/****************************************************************************
 * DpiParamValInt.svh
 ****************************************************************************/

  
/**
 * Class: DpiParamValInt
 * 
 * TODO: Add class documentation
 */
class DpiParamValInt extends IParamValInt;
	chandle			m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction
	
	virtual function kind_e kind();
		return DpiParamVal::_kind(m_hndl);
	endfunction
	
	virtual function longint val_s();
		return tblink_rpc_IParamValInt_val_s(m_hndl);
	endfunction
	
	virtual function longint unsigned val_u();
		return tblink_rpc_IParamValInt_val_u(m_hndl);
	endfunction
	
	virtual function void dispose();
		DpiParamVal::do_dispose(m_hndl);
	endfunction
	
	virtual function IParamVal clone();
		return DpiParamVal::_clone(m_hndl);
	endfunction

endclass

import "DPI-C" context function longint unsigned tblink_rpc_IParamValInt_val_u(
			chandle			hndl);
			
import "DPI-C" context function longint tblink_rpc_IParamValInt_val_s(
			chandle			hndl);


