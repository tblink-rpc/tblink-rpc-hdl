/****************************************************************************
 * DpiEndpointEvent.svh
 ****************************************************************************/

/**
 * Class: DpiEndpointEvent
 * 
 * TODO: Add class documentation
 */
class DpiEndpointEvent extends IEndpointEvent;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction

	virtual function kind_t kind();
		return Unknown;
	endfunction

endclass

import "DPI-C" context function int tblink_rpc_IEndpointEvent_kind(
	chandle hndl);


