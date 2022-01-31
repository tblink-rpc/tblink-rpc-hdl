
/****************************************************************************
 * IInterfaceImpl.svh
 ****************************************************************************/

// typedef class IParamVal;
  
/**
 * Class: IInterfaceImpl
 * 
 * TODO: Add class documentation
 */
class IInterfaceImpl;
	
	virtual function void init(IInterfaceInst ifinst);
		$display("TbLink Error: IInterfaceImpl::init not implemented");
		$finish();
	endfunction
	
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


