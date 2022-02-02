/****************************************************************************
 * InterfaceImplFactoryBase.svh
 ****************************************************************************/

/**
 * Class: InterfaceImplFactoryBase
 * 
 * TODO: Add class documentation
 */
class InterfaceImplFactoryBase #(type T) extends IInterfaceImplFactory;

	virtual function IInterfaceImpl createImpl();
		T ret = new();
		return ret;
	endfunction

endclass


