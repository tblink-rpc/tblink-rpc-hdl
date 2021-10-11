
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
		return null;
	endfunction
		
	virtual function IMethodType method();
		return null;
	endfunction
		
	virtual function IParamValVec params();
		return null;
	endfunction

	virtual function void invoke_rsp(IParamVal retval);
	endfunction
		
endclass


