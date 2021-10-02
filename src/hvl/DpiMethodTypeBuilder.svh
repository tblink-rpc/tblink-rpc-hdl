
/****************************************************************************
 * DpiMethodTypeBuilder.svh
 ****************************************************************************/

  
/**
 * Class: DpiMethodTypeBuilder
 * 
 * TODO: Add class documentation
 */
class DpiMethodTypeBuilder extends IMethodTypeBuilder;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction

endclass

import "DPI-C" context function void tblink_rpc_IMethodTypeBuilder_add_param(
	chandle		hndl,
	string		name,
	chandle		ptype_h);


