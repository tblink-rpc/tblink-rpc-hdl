
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
	endfunction
	
	virtual function IParamValInt mkValIntS(
		longint				val,
		int 				width);
	endfunction
	
	virtual function IParamValInt mkValIntU(
		longint unsigned	val,
		int 				width);
	endfunction
		
endclass


