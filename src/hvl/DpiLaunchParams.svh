/****************************************************************************
 * DpiLaunchParams.svh
 ****************************************************************************/

  
/**
 * Class: DpiLaunchParams
 * 
 * TODO: Add class documentation
 */
class DpiLaunchParams extends ILaunchParams;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction

	virtual function void add_arg(string arg);
		tblink_rpc_ILaunchParams_add_arg(m_hndl, arg);
	endfunction
	
	virtual function string_l args();
	endfunction
	
	virtual function void add_param(
		string				key,
		string				val);
		tblink_rpc_ILaunchParams_add_param(m_hndl, key, val);
	endfunction
	
	virtual function string_m params();
	endfunction

endclass

import "DPI-C" context function void tblink_rpc_ILaunchParams_add_arg(
	chandle 		hndl,
	string 			arg);
	
import "DPI-C" context function void tblink_rpc_ILaunchParams_add_param(
	chandle 		hndl,
	string			key,
	string			val);


