/*
 * DpiTbLinkListenerProxy.h
 *
 *  Created on: Jan 28, 2022
 *      Author: mballance
 */

#pragma once
#include "dpi_api.h"
#include "tblink_rpc/ITbLinkListener.h"

namespace tblink_rpc_hdl {

class DpiTbLinkListenerProxy : public tblink_rpc_core::ITbLinkListener {
public:
	DpiTbLinkListenerProxy(dpi_api_t *dpi);

	virtual ~DpiTbLinkListenerProxy();

	virtual void notify(const tblink_rpc_core::ITbLinkEvent *) override;

private:
	dpi_api_t					*m_dpi;

};

} /* namespace tblink_rpc_hdl */

