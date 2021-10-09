
/****************************************************************************
 * IParamValVec.svh
 ****************************************************************************/

  
/**
 * Class: IParamValVec
 * 
 * TODO: Add class documentation
 */
class IParamValVec extends IParamVal;
		
	virtual function int unsigned size();
		/*
		return _tblink_rpc_iparam_val_vector_size(m_hndl);
		 */
		return -1;
	endfunction
		
	virtual function IParamVal at(int unsigned idx);
		/*
		// TODO: should use a factory to get types right on the SV side
		chandle hndl = _tblink_rpc_iparam_val_vector_at(m_hndl, idx);
		IParamVal ret = IParamVal::mk(hndl);
		return ret;
		 */
		return null;
	endfunction
		
	virtual function void push_back(IParamVal v);
		/*
		_tblink_rpc_iparam_val_vector_push_back(m_hndl, v.m_hndl);
		 */
	endfunction
		
	virtual function IParamValVec clone();
		/*
		IParamValVec ret = new();
		ret.m_hndl = _tblink_rpc_iparam_val_clone(m_hndl);
		return ret;
		 */
		return null;
	endfunction
endclass


