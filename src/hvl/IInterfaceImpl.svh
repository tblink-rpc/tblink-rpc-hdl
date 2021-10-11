
/****************************************************************************
 * IInterfaceImpl.svh
 ****************************************************************************/

  
/**
 * Class: IInterfaceImpl
 * 
 * TODO: Add class documentation
 */
class IInterfaceImpl;

	// This shouldn't be needed. However, there are some cases
	// where Verilator isn't able to determine the call scope
	// and needs to reach into the class hierarchy instead
	InvokeInfo m_ii;
		
	virtual function IParamVal invoke_nb(
		input IInterfaceInst	ifinst,
		input IMethodType		method,
		input IParamValVec		params);
		$display("Error: invoke_nb not overridden");
		$finish();
		return null;
	endfunction

	virtual task invoke_b(
		output IParamVal		retval,
		input IInterfaceInst	ifinst,
		input IMethodType		method,
		IParamValVec			params);
		$display("Error: invoke not overridden");
		$finish();
	endtask
	
endclass


