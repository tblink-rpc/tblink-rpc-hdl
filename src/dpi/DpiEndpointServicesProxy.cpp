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

} /* namespace tblink_rpc_hdl */
