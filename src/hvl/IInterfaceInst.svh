
/****************************************************************************
 * IInterfaceInst.svh
 ****************************************************************************/

  
/**
 * Class: IInterfaceInst
 * 
 * TODO: Add class documentation
 */
class IInterfaceInst;
	
	virtual function void set_impl(IInterfaceImpl impl);
	endfunction
	
	virtual function IInterfaceImpl get_impl();
		return null;
	endfunction
	
	virtual function string name();
		return "";
	endfunction
	
	virtual function IInterfaceType iftype();
		return null;
	endfunction
	
	virtual function bit is_mirror();
		return 0;
	endfunction
	
	virtual function IParamVal invoke_nb(
		IMethodType					method,
		IParamValVec				params);
		return null;
	endfunction
	
	virtual task invoke_b(
		output IParamVal			retval,
		IMethodType					method,
		IParamValVec				params);
	endtask

	virtual function IParamValBool mkValBool(
		int unsigned		val);
		return null;
	endfunction
	
	virtual function IParamValInt mkValIntS(
		longint				val,
		int 				width);
		return null;
	endfunction
	
	virtual function IParamValInt mkValIntU(
		longint unsigned	val,
		int 				width);
		return null;
	endfunction
	
	virtual function IParamValMap mkValMap();
		return null;
	endfunction
	
	virtual function IParamValStr mkValStr(
		string				val);
		return null;
	endfunction
	
	virtual function IParamValVec mkValVec();
		return null;
	endfunction
		
endclass


