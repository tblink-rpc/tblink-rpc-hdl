/****************************************************************************
 * TbLinkInvokeB.svh
 ****************************************************************************/

  
class TbLinkInvokeB extends TbLinkThread;
	InvokeInfo				m_ii;
	
	function new(InvokeInfo ii);
		m_ii = ii;
	endfunction
	
	virtual task run();
		IInterfaceInst ifinst = m_ii.inst();
		IInterfaceImpl ifimpl = ifinst.get_impl();
		//			chandle ifinst = tblink_rpc_InvokeInfo_ifinst(m_ii.m_hndl);
		//			IInterfaceImpl ifimpl = ifinst2impl_m[ifinst];

		$display("--> invoke_b");
		ifimpl.invoke_b(m_ii);
		$display("<-- invoke_b");
	endtask
endclass


