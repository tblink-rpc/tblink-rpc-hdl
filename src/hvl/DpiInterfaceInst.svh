
/****************************************************************************
 * DpiInterfaceInst.svh
 ****************************************************************************/

typedef class DpiParamValInt;

IInterfaceImpl prv_hndl2impl[chandle];
  
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
	endfunction
	
	virtual function IParamValStr mkValStr(
		string				val);
	endfunction
	
	virtual function IParamValVec mkValVec();
	endfunction	

endclass

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

