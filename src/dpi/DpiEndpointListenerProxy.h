/*
 * DpiEndpointListenerProxy.h
 *
 *  Created on: Dec 10, 2021
 *      Author: mballance
 */

#pragma once
#include "dpi_api.h"
#include "tblink_rpc/IEndpointListener.h"

namespace tblink_rpc_core {

class DpiEndpointListenerProxy : public IEndpointListener {
public:
	DpiEndpointListenerProxy(dpi_api_t *dpi_api);

	virtual ~DpiEndpointListenerProxy();

	virtual void event(const IEndpointEvent *ev) override;

private:
	dpi_api_t						*m_dpi_api;

};

} /* namespace tblink_rpc_core */

