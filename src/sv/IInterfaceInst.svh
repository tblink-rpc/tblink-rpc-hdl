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
	
	virtual function IEndpoint endpoint();
		$display("TbLink Error: IInterfaceInst::endpoint not implemented");
		$finish();
		return null;
	endfunction
	
	virtual function string name();
		$display("TbLink Error: IInterfaceInst::name not implemented");
		$finish();
		return "";
	endfunction
	
	virtual function IInterfaceType iftype();
		$display("TbLink Error: IInterfaceInst::iftype not implemented");
		$finish();
		return null;
	endfunction
	
	virtual function bit is_mirror();
		$display("TbLink Error: IInterfaceInst::is_mirror not implemented");
		$finish();
		return 0;
	endfunction
	
	virtual function IParamVal invoke_nb(
		IMethodType					method,
		IParamValVec				params);
		$display("TbLink Error: IInterfaceInst::invoke_nb not implemented");
		$finish();
		return null;
	endfunction
	
	virtual task invoke_b(
		output IParamVal			retval,
		input  IMethodType			method,
		input  IParamValVec			params);
		$display("TbLink Error: IInterfaceInst::invoke_b not implemented");
		$finish();
	endtask
	
	virtual function void invoke_rsp(
		longint						call_id,
		IParamVal					retval);
	endfunction

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


