/****************************************************************************
 * DpiInterfaceImplFactoryProxy.svh
 ****************************************************************************/

IInterfaceImplFactory	prv_dpi_ifimpl_factory_m[chandle];

function automatic chandle newDpiInterfaceImplFactoryProxy(
	IInterfaceImplFactory		factory);
	chandle proxy = tblink_rpc_DpiInterfaceImplFactoryProxy_new();
	prv_dpi_ifimpl_factory_m[proxy] = factory;
	return proxy;
endfunction

import "DPI-C" context function chandle tblink_rpc_DpiInterfaceImplFactoryProxy_new();

function automatic chandle tblink_rpc_DpiInterfaceImplFactory_createImpl(
	chandle			proxy);
	chandle ifimpl_h;
	IInterfaceImplFactory f = prv_dpi_ifimpl_factory_m[proxy];
	IInterfaceImpl impl = f.createImpl();
	ifimpl_h = newDpiInterfaceImplProxy(impl);
	return ifimpl_h;
endfunction
export "DPI-C" function tblink_rpc_DpiInterfaceImplFactory_createImpl;

//function automatic 
	

