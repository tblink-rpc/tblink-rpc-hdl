
/****************************************************************************
 * DpiInvokeInfo.svh
 ****************************************************************************/

typedef class DpiMethodType;
typedef class DpiParamVal;
  
/**
 * Class: DpiInvokeInfo
 * 
 * TODO: Add class documentation
 */
class DpiInvokeInfo extends InvokeInfo;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction

	virtual function IInterfaceInst inst();
		DpiInterfaceInst ret;
		chandle hndl = tblink_rpc_InvokeInfo_ifinst(m_hndl);
		ret = new(hndl);
		
		return ret;
	endfunction
		
	virtual function IMethodType method();
		DpiMethodType ret;
		chandle hndl = tblink_rpc_InvokeInfo_method(m_hndl);
		ret = new(hndl);

		return ret;
	endfunction
		
	virtual function IParamValVec params();
		IParamValVec ret;
		chandle params_h = tblink_rpc_InvokeInfo_params(m_hndl);
		IParamVal params_v = DpiParamVal::mk(params_h);
		
		`DYN_CAST(ret, params_v);
		
		return ret;
	endfunction

	virtual function void invoke_rsp(IParamVal retval);
		chandle retval_h;
		
		if (retval != null) begin
			DpiParamVal retval_dpi;
			`DYN_CAST(retval_dpi, retval);
			retval_h = retval_dpi.m_hndl;
		end
		
		tblink_rpc_InvokeInfo_invoke_rsp(m_hndl, retval_h);
	endfunction

endclass

import "DPI-C" context function chandle tblink_rpc_InvokeInfo_ifinst(chandle hndl);
import "DPI-C" context function chandle tblink_rpc_InvokeInfo_method(chandle hndl);
import "DPI-C" context function chandle tblink_rpc_InvokeInfo_params(chandle ii_h);
import "DPI-C" context function void tblink_rpc_InvokeInfo_invoke_rsp(
	chandle 	ii_h,
	chandle		retval_h);

