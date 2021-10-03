/****************************************************************************
 * DpiParamValMap.svh
 ****************************************************************************/

  
/**
 * Class: DpiParamValMap
 * 
 * TODO: Add class documentation
 */
class DpiParamValMap extends IParamValMap;
	chandle			m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction
	
	virtual function bit hasKey(string key);
		return tblink_rpc_IParamValMap_hasKey(m_hndl, key) != 0;
	endfunction
	
	virtual function IParamVal getVal(string key);
		chandle val_h = tblink_rpc_IParamValMap_getVal(m_hndl, key);
		IParamVal ret = DpiParamVal::mk(val_h);
	endfunction
	
	virtual function setVal(string key, IParamVal val);
		chandle val_h = DpiParamVal::getHndl(val);
		tblink_rpc_IParamValMap_setVal(
				m_hndl,
				key,
				val_h);
	endfunction


endclass

import "DPI-C" context function int unsigned tblink_rpc_IParamValMap_hasKey(
	chandle			map_h,
	string			key);
import "DPI-C" context function chandle tblink_rpc_IParamValMap_getVal(
	chandle			map_h,
	string			key);
import "DPI-C" context function void tblink_rpc_IParamValMap_setVal(
	chandle			map_h,
	string			key,
	chandle			val_h);


