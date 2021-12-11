/*
 * DpiEndpointLoopbackVpi.cpp
 *
 *  Created on: Dec 8, 2021
 *      Author: mballance
 */

#include "DpiEndpointLoopbackVpi.h"

namespace tblink_rpc_hdl {

DpiEndpointLoopbackVpi::DpiEndpointLoopbackVpi(
		dpi_api_t 					*dpi_api,
		DpiEndpointLoopbackVpi		*peer) :
	m_dpi_api(dpi_api), m_peer(peer), m_primary(!peer) {

	fprintf(stdout, "DpiEndpointLoopbackVpi: this=%p peer=%p\n", this, peer);
	if (m_primary) {
		m_peer = new DpiEndpointLoopbackVpi(dpi_api, this);
	}
}

DpiEndpointLoopbackVpi::~DpiEndpointLoopbackVpi() {
	// TODO Auto-generated destructor stub
}

int32_t DpiEndpointLoopbackVpi::process_one_message() {
	int32_t ret = 0;

	while (m_rsp_q.size() || m_req_q.size()) {
		ret = 1;

		while (m_rsp_q.size()) {
			Rsp rsp = m_rsp_q.front();
			m_rsp_q.erase(m_rsp_q.begin());
			recv_rsp(rsp.id, rsp.result, rsp.error);
		}

		while (m_req_q.size()) {
			Req req = m_req_q.front();
			m_req_q.erase(m_req_q.begin());
			recv_req(req.method, req.id, req.params);
		}
	}

	return ret;
}

int32_t DpiEndpointLoopbackVpi::send_req(
		const std::string		&method,
		intptr_t				id,
		IParamValMap			*params) {
	return m_peer->peer_recv_req(method, id, params);
}

int32_t DpiEndpointLoopbackVpi::peer_recv_req(
		const std::string		&method,
		intptr_t				id,
		IParamValMap			*params) {
	if (m_primary) {
		m_req_q.push_back({method, id, params});
		fprintf(stdout, "TODO: toggle VPI event\n");
		m_dpi_api->toggle_vpi_ev();
	} else {
		fprintf(stdout, "TODO: pass directly to foreign\n");
		recv_req(method, id, params);
	}
	return 0;
}

int32_t DpiEndpointLoopbackVpi::send_rsp(
		intptr_t				id,
		IParamValMap			*result,
		IParamValMap			*error) {
	return m_peer->peer_recv_rsp(id, result, error);
}

int32_t DpiEndpointLoopbackVpi::peer_recv_rsp(
		intptr_t				id,
		IParamValMap			*result,
		IParamValMap			*error) {
	if (m_primary) {
		m_rsp_q.push_back({id, result, error});
		fprintf(stdout, "TODO: toggle VPI event\n");
		m_dpi_api->toggle_vpi_ev();
	} else {
		fprintf(stdout, "TODO: pass directly to foreign\n");
		recv_rsp(id, result, error);
	}
	return 0;
}

} /* namespace tblink_rpc_hdl */
