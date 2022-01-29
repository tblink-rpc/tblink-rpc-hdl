/*
 * DpiTbLinkListenerProxy.cpp
 *
 *  Created on: Jan 28, 2022
 *      Author: mballance
 */

#include "DpiTbLinkListenerProxy.h"

namespace tblink_rpc_hdl {

using namespace tblink_rpc_core;

DpiTbLinkListenerProxy::DpiTbLinkListenerProxy(dpi_api_t *dpi) : m_dpi(dpi) {
	// TODO Auto-generated constructor stub

}

DpiTbLinkListenerProxy::~DpiTbLinkListenerProxy() {
	// TODO Auto-generated destructor stub
}

void DpiTbLinkListenerProxy::notify(
		const tblink_rpc_core::ITbLinkEvent *ev) {
	m_dpi->tbl_proxy_notify(
			reinterpret_cast<void *>(
					static_cast<ITbLinkListener *>(this)),
			reinterpret_cast<void *>(
					const_cast<ITbLinkEvent *>(ev)));
}

} /* namespace tblink_rpc_hdl */
