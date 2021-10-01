
/****************************************************************************
 * InvokeInfo.svh
 ****************************************************************************/

  
/**
 * Class: InvokeInfo
 * 
 * TODO: Add class documentation
 */
class InvokeInfo;
		
	virtual function IInterfaceInst inst();
	endfunction
		
	virtual function IMethodType method();
	endfunction
		
	virtual function IParamValVec params();
	endfunction

	virtual function void invoke_rsp(IParamVal retval);
	endfunction
		
endclass


