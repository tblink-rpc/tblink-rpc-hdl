
/****************************************************************************
 * DpiMethodType.svh
 ****************************************************************************/

  
/**
 * Class: DpiMethodType
 * 
 * TODO: Add class documentation
 */
class DpiMethodType extends IMethodType;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction
	
	virtual function string name();
		return tblink_rpc_IMethodType_name(m_hndl);
	endfunction
		
	virtual function longint id();
		return tblink_rpc_IMethodType_id(m_hndl);
	endfunction	
	
	virtual function bit is_export();
		return tblink_rpc_IMethodType_is_export(m_hndl)!=0;
	endfunction
	
	virtual function bit is_blocking();
		return tblink_rpc_IMethodType_is_blocking(m_hndl)!=0;
	endfunction

endclass

import "DPI-C" context function string tblink_rpc_IMethodType_name(chandle hndl);
import "DPI-C" context function longint tblink_rpc_IMethodType_id(chandle hndl);
import "DPI-C" context function int unsigned tblink_rpc_IMethodType_is_export(chandle hndl);
import "DPI-C" context function int unsigned tblink_rpc_IMethodType_is_blocking(chandle hndl);

