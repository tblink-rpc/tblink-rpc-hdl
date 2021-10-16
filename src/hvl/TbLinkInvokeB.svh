/****************************************************************************
 * TbLinkInvokeB.svh
 ****************************************************************************/

  
class TbLinkInvokeB extends TbLinkThread;
	IInterfaceInst			m_ifinst;
	IMethodType				m_method;
	longint					m_call_id;
	IParamValVec			m_params;
	
	function new(
		IInterfaceInst		ifinst,
		IMethodType			method,
		longint				call_id,
		IParamValVec		params);
		m_ifinst = ifinst;
		m_method = method;
		m_call_id = call_id;
		m_params = params;
	endfunction
	
	virtual task run();
		IInterfaceImpl ifimpl = m_ifinst.get_impl();
		IParamVal retval;
		//			chandle ifinst = tblink_rpc_InvokeInfo_ifinst(m_ii.m_hndl);
		//			IInterfaceImpl ifimpl = ifinst2impl_m[ifinst];

		ifimpl.invoke_b(
				retval,
				m_ifinst,
				m_method,
				m_params);

		// These params are cloned
		m_params.dispose();
		
		m_ifinst.invoke_rsp(m_call_id, retval);
	endtask
endclass


