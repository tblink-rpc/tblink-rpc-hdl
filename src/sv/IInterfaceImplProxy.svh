/****************************************************************************
 * IInterfaceImplProxy.svh
 ****************************************************************************/

  
/**
 * Class: IInterfaceImplProxy
 * 
 * TODO: Add class documentation
 */
class IInterfaceImplProxy extends IInterfaceImpl;

	virtual function void init(IInterfaceInst ifinst);
		$display("TbLink Error: IInterfaceImplProxy::init unimplemented");
		$finish(1);
	endfunction
	
	virtual function bit is_mirror();
		$display("TbLink Error: IInterfaceImplProxy::is_mirror unimplemented");
		$finish(1);
		return 0;
	endfunction

endclass


