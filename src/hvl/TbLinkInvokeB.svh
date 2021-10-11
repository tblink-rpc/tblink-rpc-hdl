/****************************************************************************
 * TbLinkInvokeB.svh
 ****************************************************************************/

  
class TbLinkInvokeB extends TbLinkThread;
	IInterfaceInst			m_ifinst;
	IMethodType				m_method;
	IParamValVec			m_params;
	
	function new(
		IInterfaceInst		ifinst,
		IMethodType			method,
		IParamValVec		params);
		m_ifinst = ifinst;
		m_method = method;
		m_params = params;
	endfunction
	
	virtual task run();
		IInterfaceImpl ifimpl = m_ifinst.get_impl();
		IParamVal retval;
		//			chandle ifinst = tblink_rpc_InvokeInfo_ifinst(m_ii.m_hndl);
		//			IInterfaceImpl ifimpl = ifinst2impl_m[ifinst];

		$display("--> invoke_b");
		ifimpl.invoke_b(
				retval,
				m_ifinst,
				m_method,
				m_params);
		$display("<-- invoke_b");
	endtask
endclass


