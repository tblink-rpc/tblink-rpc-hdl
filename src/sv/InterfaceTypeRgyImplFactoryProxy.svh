
/****************************************************************************
 * InterfaceTypeRgyImplFactoryProxy.svh
 ****************************************************************************/

/**
 * Class: InterfaceTypeRgyImplFactoryProxy
 * 
 * TODO: Add class documentation
 */
class InterfaceTypeRgyImplFactoryProxy extends IInterfaceImplFactory;
	
	InterfaceTypeRgyBasePrv		m_iftype_rgy;

	function new(InterfaceTypeRgyBasePrv iftype_rgy);
		m_iftype_rgy = iftype_rgy;
	endfunction

	virtual function tblink_rpc::IInterfaceImplFactory getImplFactory();
		return m_iftype_rgy.getRegisteredImplFactory();
	endfunction

endclass


