/****************************************************************************
 * DpiParamValVec.svh
 ****************************************************************************/
  
/**
 * Class: DpiParamValVec
 * 
 * TODO: Add class documentation
 */
class DpiParamValVec extends IParamValVec;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction
	
	virtual function kind_e kind();
		return DpiParamVal::_kind(m_hndl);
	endfunction
	
	virtual function int unsigned size();
		return tblink_rpc_IParamValVec_size(m_hndl);
	endfunction	

	virtual function IParamVal at(int unsigned idx);
		chandle elem_h = tblink_rpc_IParamValVec_at(m_hndl, idx);
		IParamVal ret = DpiParamVal::mk(elem_h);
		return ret;
	endfunction
	
	virtual function void push_back(IParamVal v);
		chandle v_hndl = DpiParamVal::getHndl(v);
		tblink_rpc_IParamValVec_push_back(m_hndl, v_hndl);
	endfunction
	
	virtual function void dispose();
		DpiParamVal::do_dispose(m_hndl);
	endfunction
	
	virtual function IParamVal clone();
		return DpiParamVal::_clone(m_hndl);
	endfunction

endclass

import "DPI-C" context function int unsigned tblink_rpc_IParamValVec_size(
	chandle			hndl);
import "DPI-C" context function chandle tblink_rpc_IParamValVec_at(
	chandle			hndl,
	int unsigned	idx);
import "DPI-C" context function void tblink_rpc_IParamValVec_push_back(
	chandle			hndl,
	chandle			val_h);

