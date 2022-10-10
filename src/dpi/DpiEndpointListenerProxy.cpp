/*
 * DpiEndpointListenerProxy.cpp
 *
 *  Created on: Dec 10, 2021
 *      Author: mballance
 */

#include <stdio.h>
#include "DpiEndpointListenerProxy.h"

namespace tblink_rpc_core {

DpiEndpointListenerProxy::DpiEndpointListenerProxy(
		dpi_api_t	*dpi_api) : m_dpi_api(dpi_api) {
	// TODO Auto-generated constructor stub

}

DpiEndpointListenerProxy::~DpiEndpointListenerProxy() {
	// TODO Auto-generated destructor stub
}

void DpiEndpointListenerProxy::event(const IEndpointEvent *ev) {
	fprintf(stdout, "DpiEndpointListenerProxy::event: scope=%p\n",
			m_dpi_api->get_pkg_scope());
	fflush(stdout);
	m_dpi_api->svSetScope(m_dpi_api->get_pkg_scope());
	m_dpi_api->epl_event(
			reinterpret_cast<void *>(this),
			reinterpret_cast<void *>(const_cast<IEndpointEvent *>(ev)));
}

} /* namespace tblink_rpc_core */
