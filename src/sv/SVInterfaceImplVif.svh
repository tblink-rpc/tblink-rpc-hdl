
/****************************************************************************
 * SVInterfaceImplVif.svh
 ****************************************************************************/

  
/**
 * Class: SVInterfaceImplVif
 * 
 * Interface implementation class that redirects to a virtual interface
 */
class SVInterfaceImplVif #(type VIF=IInterfaceImpl) extends IInterfaceImpl;
	VIF					m_vif;
	IInterfaceInst		m_ifinst;

	function new(VIF vif);
		m_vif = vif;
	endfunction
	
	virtual function void init(IInterfaceInst ifinst);
		m_ifinst = ifinst;
	endfunction

	virtual function IParamVal invoke_nb(
		input IInterfaceInst		ifinst,
		input IMethodType			method,
		input IParamValVec			params);
		return m_vif.invoke_nb(ifinst, method, params);
	endfunction

	virtual task invoke_b(
		output IParamVal			retval,
		input IInterfaceInst		ifinst,
		input IMethodType			method,
		input IParamValVec			params);
		m_vif.invoke_b(retval, ifinst, method, params);
	endtask	

endclass


