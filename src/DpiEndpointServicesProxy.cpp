/*
 * DpiEndpointServicesProxy.cpp
 *
 *  Created on: Nov 18, 2021
 *      Author: mballance
 */

#include "DpiEndpointServicesProxy.h"

namespace tblink_rpc_hdl {

DpiEndpointServicesProxy::DpiEndpointServicesProxy(dpi_api_t *dpi_api) :
		m_dpi_api(dpi_api) {

}

DpiEndpointServicesProxy::~DpiEndpointServicesProxy() {
	// TODO Auto-generated destructor stub
}

void DpiEndpointServicesProxy::init(tblink_rpc_core::IEndpoint *endpoint) {
	// NOP. SV side handles initialization
}

/**
 * Return command-line arguments.
 */
std::vector<std::string> DpiEndpointServicesProxy::args() {
	// TODO:
	return {};
}

void DpiEndpointServicesProxy::shutdown() {
	m_dpi_api->eps_proxy_shutdown(
			reinterpret_cast<void *>(
					static_cast<IEndpointServices *>(this)));
}

int32_t DpiEndpointServicesProxy::add_time_cb(
		uint64_t 		time,
		intptr_t		callback_id) {
	// TODO:
	return -1;
}

void DpiEndpointServicesProxy::cancel_callback(intptr_t id) {
	// TODO:

}

uint64_t DpiEndpointServicesProxy::time() {
	// TODO:
	return 0;
}

/**
 * Returns the time precision as an exponent:
 * 0: 1s
 * -3: 1ms
 * -6: 1us
 * -9: 1ns
 * -12: 1ps
 */
int32_t DpiEndpointServicesProxy::time_precision() {
	// TODO:
	return -9;
}

// Release the environment to run
void DpiEndpointServicesProxy::run_until_event() {
	m_dpi_api->svSetScope(m_dpi_api->get_pkg_scope());
	m_dpi_api->eps_proxy_run_until_event(
			reinterpret_cast<void *>(
					static_cast<IEndpointServices *>(this)));
}

// Notify that we've hit an event
void DpiEndpointServicesProxy::hit_event() {
	m_dpi_api->svSetScope(m_dpi_api->get_pkg_scope());
	m_dpi_api->eps_proxy_hit_event(
			reinterpret_cast<void *>(
					static_cast<IEndpointServices *>(this)));
}

void DpiEndpointServicesProxy::idle() {
	m_dpi_api->svSetScope(m_dpi_api->get_pkg_scope());
	m_dpi_api->eps_proxy_idle(
			reinterpret_cast<void *>(
					static_cast<IEndpointServices *>(this)));
}

} /* namespace tblink_rpc_hdl */
