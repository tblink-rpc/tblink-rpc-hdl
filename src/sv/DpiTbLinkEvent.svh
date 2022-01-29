/****************************************************************************
 * DpiTbLinkEvent.svh
 ****************************************************************************/

  
/**
 * Class: DpiTbLinkEvent
 * 
 * TODO: Add class documentation
 */
class DpiTbLinkEvent extends ITbLinkEvent;
	chandle			m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction
	
	virtual function TbLinkEventKind_t kind();
		return TbLinkEventKind_t'(tblink_rpc_ITbLinkEvent_kind(m_hndl));
	endfunction

endclass

import "DPI-C" context function int tblink_rpc_ITbLinkEvent_kind(chandle ev);


