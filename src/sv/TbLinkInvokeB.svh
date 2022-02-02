/****************************************************************************
 * TbLinkInvokeB.svh
 ****************************************************************************/

  
class TbLinkInvokeB extends TbLinkThread;
	IInterfaceImpl			m_ifimpl;
	IInterfaceInst			m_ifinst;
	IMethodType				m_method;
	longint					m_call_id;
	IParamValVec			m_params;
	
	function new(
		IInterfaceImpl		ifimpl,
		IInterfaceInst		ifinst,
		IMethodType			method,
		longint				call_id,
		IParamValVec		params);
		m_ifimpl = ifimpl;
		m_ifinst = ifinst;
		m_method = method;
		m_call_id = call_id;
		m_params = params;
	endfunction
	
	virtual task run();
		IParamVal retval;

		m_ifimpl.invoke_b(
				retval,
				m_ifinst,
				m_method,
				m_params);

		// These params are cloned
		// TODO:
		m_params.dispose();

		m_ifinst.invoke_rsp(m_call_id, retval);
	endtask
endclass


