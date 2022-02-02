/*
 * DpiInterfaceImplFactoryProxy.h
 *
 *  Created on: Feb 2, 2022
 *      Author: mballance
 */

#pragma once
#include "dpi_api.h"
#include "tblink_rpc/IInterfaceImplFactory.h"

namespace tblink_rpc_hdl {

class DpiInterfaceImplFactoryProxy : public tblink_rpc_core::IInterfaceImplFactory {
public:
	DpiInterfaceImplFactoryProxy(dpi_api_t *dpi);

	virtual ~DpiInterfaceImplFactoryProxy();

	virtual tblink_rpc_core::IInterfaceImpl *createImpl() override;

private:
	dpi_api_t						*m_dpi;

};

} /* namespace tblink_rpc_hdl */

