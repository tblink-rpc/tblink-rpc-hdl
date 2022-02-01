/****************************************************************************
 * InterfaceImplFactory.svh
 ****************************************************************************/

  
/**
 * Class: InterfaceImplFactory
 * 
 * TODO: Add class documentation
 */
class InterfaceImplFactory #(type T) extends IInterfaceImplFactoryBase;

	virtual function IInterfaceImpl createImpl();
		T impl = new();
		return impl;
	endfunction

endclass


