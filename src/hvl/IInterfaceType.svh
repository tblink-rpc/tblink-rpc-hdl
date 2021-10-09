
/****************************************************************************
 * IInterfaceType.svh
 ****************************************************************************/

  
/**
 * Class: IInterfaceType
 * 
 * TODO: Add class documentation
 */
class IInterfaceType;
	
	typedef IMethodType method_l[$];
	
	virtual function string name();
		return "";
	endfunction

	virtual function method_l methods();
		method_l ret;
		return ret;
	endfunction
	
	virtual function IMethodType findMethod(string name);
		return null;
	endfunction
	
endclass

