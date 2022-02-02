/*
 * DpiInterfaceImplFactoryProxy.cpp
 *
 *  Created on: Feb 2, 2022
 *      Author: mballance
 */

#include "DpiInterfaceImplFactoryProxy.h"

namespace tblink_rpc_hdl {
using namespace tblink_rpc_core;

DpiInterfaceImplFactoryProxy::DpiInterfaceImplFactoryProxy(dpi_api_t *dpi) :
		m_dpi(dpi) {

}

DpiInterfaceImplFactoryProxy::~DpiInterfaceImplFactoryProxy() {
	// TODO Auto-generated destructor stub
}

IInterfaceImpl *DpiInterfaceImplFactoryProxy::createImpl() {
	return reinterpret_cast<IInterfaceImpl *>(
			m_dpi->ifimpl_factory_proxy_createImpl(
					reinterpret_cast<void *>(
							dynamic_cast<IInterfaceImplFactory *>(this))));
}

} /* namespace tblink_rpc_hdl */
