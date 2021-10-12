
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
		return -1;
	endfunction
		
	virtual function IParamVal at(int unsigned idx);
		return null;
	endfunction
		
	virtual function void push_back(IParamVal v);
	endfunction

`ifdef UNDEFINED
	virtual function IParamValVec clone();
		/*
		IParamValVec ret = new();
		ret.m_hndl = _tblink_rpc_iparam_val_clone(m_hndl);
		return ret;
		 */
		return null;
	endfunction
`endif
endclass


