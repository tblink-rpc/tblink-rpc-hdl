
/****************************************************************************
 * DpiInterfaceInst.svh
 ****************************************************************************/

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

endclass


