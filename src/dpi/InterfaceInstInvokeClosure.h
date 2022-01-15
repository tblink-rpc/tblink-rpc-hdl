/*
 * InterfaceInstInvokeClosure.h
 *
 *  Created on: Dec 14, 2021
 *      Author: mballance
 */

#pragma once
#include "dpi_api.h"
#include "tblink_rpc/IParamVal.h"

namespace tblink_rpc_hdl {

class InterfaceInstInvokeClosure {
public:
	InterfaceInstInvokeClosure(dpi_api_t *dpi_api);

	virtual ~InterfaceInstInvokeClosure();

	void response_f(tblink_rpc_core::IParamVal *retval);

private:
	dpi_api_t							*m_dpi_api;
};

} /* namespace tblink_rpc_hdl */

