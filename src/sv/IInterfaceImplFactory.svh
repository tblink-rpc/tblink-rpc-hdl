/****************************************************************************
 * IInterfaceImplFactory.svh
 ****************************************************************************/

  
/**
 * Class: IInterfaceImplFactory
 * 
 * TODO: Add class documentation
 */
class IInterfaceImplFactory;
	
	virtual function IInterfaceImpl createImpl();
		$display("TbLink Error: IInterfaceImplFactory::createImpl unimplemented");
		$finish();
		return null;
	endfunction

endclass


