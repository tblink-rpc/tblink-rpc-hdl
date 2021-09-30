
/****************************************************************************
 * InvokeInfo.svh
 ****************************************************************************/

  
/**
 * Class: InvokeInfo
 * 
 * TODO: Add class documentation
 */
class InvokeInfo;
	chandle					m_hndl;
		
	function new(chandle hndl);
		m_hndl = hndl;
	endfunction
		
	function IInterfaceInst inst();
		IInterfaceInst ret = new();
		ret.m_hndl = tblink_rpc_InvokeInfo_ifinst(m_hndl);
		return ret;
	endfunction
		
	function IMethodType method();
		IMethodType ret = new();
		ret.m_hndl = tblink_rpc_InvokeInfo_method(m_hndl);
		return ret;
	endfunction
		
	function IParamValVec params();
		IParamValVec ret = new();
		ret.m_hndl = tblink_rpc_InvokeInfo_params(m_hndl);
		return ret;
	endfunction

	function void invoke_rsp();
		tblink_rpc_InvokeInfo_invoke_rsp(m_hndl, null);
	endfunction
		
endclass


