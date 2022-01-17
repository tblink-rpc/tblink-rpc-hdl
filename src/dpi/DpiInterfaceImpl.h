/*
 * DpiInterfaceImpl.h
 *
 *  Created on: Jan 15, 2022
 *      Author: mballance
 */

#pragma once
#include "dpi_api.h"
#include "tblink_rpc/IInterfaceImpl.h"

namespace tblink_rpc_hdl {

class DpiInterfaceImpl : public tblink_rpc_core::IInterfaceImpl {
public:
	DpiInterfaceImpl(dpi_api_t *dpi);

	virtual ~DpiInterfaceImpl();

	virtual void invoke(
			tblink_rpc_core::IInterfaceInst		*ifinst,
			tblink_rpc_core::IMethodType		*method,
			intptr_t							call_id,
			tblink_rpc_core::IParamValVec		*params) override;

private:
	dpi_api_t				*m_dpi;

};

} /* namespace tblink_rpc_hdl */

