/*
 * DpiEndpointLoopback.cpp
 *
 *  Created on: Dec 8, 2021
 *      Author: mballance
 */

#include "DpiEndpointLoopback.h"

namespace tblink_rpc_hdl {

DpiEndpointLoopback::DpiEndpointLoopback(
		dpi_api_t 					*dpi_api,
		DpiEndpointLoopback		*peer) :
	m_dpi_api(dpi_api), m_peer(peer), m_primary(!peer) {

	fprintf(stdout, "DpiEndpointLoopback: this=%p peer=%p\n", this, peer);
	if (m_primary) {
		m_peer = new DpiEndpointLoopback(dpi_api, this);
	}
}

DpiEndpointLoopback::~DpiEndpointLoopback() {
	// TODO Auto-generated destructor stub
}

int32_t DpiEndpointLoopback::process_one_message() {
	return 0;
}

int32_t DpiEndpointLoopback::send_req(
		const std::string		&method,
		intptr_t				id,
		IParamValMap			*params) {
	return m_peer->peer_recv_req(method, id, params);
}

int32_t DpiEndpointLoopback::peer_recv_req(
		const std::string		&method,
		intptr_t				id,
		IParamValMap			*params) {
	fprintf(stdout, "TODO: pass directly to foreign\n");
	recv_req(method, id, params);
	return 0;
}

int32_t DpiEndpointLoopback::send_rsp(
		intptr_t				id,
		IParamValMap			*result,
		IParamValMap			*error) {
	return m_peer->peer_recv_rsp(id, result, error);
}

int32_t DpiEndpointLoopback::peer_recv_rsp(
		intptr_t				id,
		IParamValMap			*result,
		IParamValMap			*error) {
	fprintf(stdout, "TODO: pass directly to foreign\n");
	recv_rsp(id, result, error);
	return 0;
}

} /* namespace tblink_rpc_hdl */
