
/****************************************************************************
 * DpiInterfaceInst.svh
 ****************************************************************************/

typedef class DpiParamValInt;

IInterfaceImpl prv_hndl2impl[chandle];

typedef class DpiParamValMap;
typedef class DpiParamValStr;
  
/**
 * Class: DpiInterfaceInst
 * 
 * TODO: Add class documentation
 */
class DpiInterfaceInst extends IInterfaceInst;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction

	virtual function void set_impl(IInterfaceImpl impl);
		prv_hndl2impl[m_hndl] = impl;
	endfunction
	
	virtual function IInterfaceImpl get_impl();
		return prv_hndl2impl[m_hndl];
	endfunction
	
	virtual function IParamVal invoke_nb(
		IMethodType					method,
		IParamValVec				params);
		DpiMethodType method_dpi;
		chandle params_h;
		
		$cast(method_dpi, method);
		params_h = DpiParamVal::getHndl(params);
		
		$display("TbLink Error: IInterfaceInst::invoke_nb not implemented");
		$finish();
		return null;
	endfunction
	
	virtual task invoke_b(
		output IParamVal			retval,
		input  IMethodType			method,
		input  IParamValVec			params);
		retval = null;
		$display("TbLink Error: IInterfaceInst::invoke_b not implemented");
		$finish();
	endtask
	
	virtual function void invoke_rsp(
		longint				call_id,
		IParamVal			retval);
		chandle		retval_h;
		
		retval_h = DpiParamVal::getHndl(retval);
		
		tblink_rpc_IInterfaceInst_invoke_rsp(m_hndl, call_id, retval_h);
	endfunction
		
	
	virtual function IParamValBool mkValBool(
		int unsigned		val);
	endfunction
	
	virtual function IParamValInt mkValIntS(
		longint				val,
		int 				width);
		DpiParamValInt ret;
		chandle val_h;
	        val_h = tblink_rpc_IInterfaceInst_mkValIntS(
				m_hndl,
				val,
				width);
		
		ret = new(val_h);
		
		return ret;
	endfunction
	
	virtual function IParamValInt mkValIntU(
		longint unsigned	val,
		int 				width);
		DpiParamValInt ret;
		chandle val_h;
	        val_h = tblink_rpc_IInterfaceInst_mkValIntU(
				m_hndl,
				val,
				width);
		
		ret = new(val_h);
		
		return ret;
	endfunction
	
	virtual function IParamValMap mkValMap();
		chandle val_h;
		DpiParamValMap ret;
		val_h = tblink_rpc_IInterfaceInst_mkValMap(m_hndl);
		ret = new(val_h);
		return ret;
	endfunction
	
	virtual function IParamValStr mkValStr(
		string				val);
		chandle val_h;
		DpiParamValStr ret;
		
		val_h = tblink_rpc_IInterfaceInst_mkValStr(
				m_hndl,
				val);
		ret = new(val_h);
		return ret;
	endfunction
	
	virtual function IParamValVec mkValVec();
		chandle val_v = tblink_rpc_IInterfaceInst_mkValVec(m_hndl);
		DpiParamValVec ret = new(val_v);
		return ret;
	endfunction	

endclass

import "DPI-C" context function void tblink_rpc_IInterfaceInst_invoke_rsp(
		chandle			ifinst,
		longint			call_id,
		chandle			retval);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValBool(
		chandle			ifinst,
		int unsigned	val);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValIntU(
		chandle				ifinst,
		longint unsigned	val,
		int unsigned		width);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValIntS(
		chandle				ifinst,
		longint				val,
		int unsigned		width);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValMap(
		chandle				ifinst);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValStr(
		chandle				ifinst,
		string				val);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValVec(
		chandle				ifinst);

