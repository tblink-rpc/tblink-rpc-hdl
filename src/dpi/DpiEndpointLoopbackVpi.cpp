/*
 * DpiEndpointLoopbackVpi.cpp
 *
 *  Created on: Dec 8, 2021
 *      Author: mballance
 */

#include "Debug.h"
#include "DpiEndpointLoopbackVpi.h"

#define EN_DEBUG_DPI_ENDPOINT_LOOPBACK_VPI

#ifdef EN_DEBUG_DPI_ENDPOINT_LOOPBACK_VPI
#define DEBUG_ENTER(fmt, ...) \
	DEBUG_ENTER_BASE(DpiEndpointLoopbackVpi, fmt, ##__VA_ARGS__)
#define DEBUG_LEAVE(fmt, ...) \
	DEBUG_LEAVE_BASE(DpiEndpointLoopbackVpi, fmt, ##__VA_ARGS__)
#define DEBUG(fmt, ...) \
	DEBUG_BASE(DpiEndpointLoopbackVpi, fmt, ##__VA_ARGS__)
#else
#define DEBUG_ENTER(fmt, ...)
#define DEBUG_LEAVE(fmt, ...)
#define DEBUG(fmt, ...)
#endif

namespace tblink_rpc_hdl {

DpiEndpointLoopbackVpi::DpiEndpointLoopbackVpi(
		dpi_api_t 					*dpi_api,
		DpiEndpointLoopbackVpi		*peer) :
	m_dpi_api(dpi_api), m_peer(peer), m_primary(!peer),
	m_in_dpi_call(0) {

	if (m_primary) {
		setFlag(IEndpointFlags::Claimed);
		setFlag(IEndpointFlags::LoopbackPri);
	} else {
		setFlag(IEndpointFlags::LoopbackSec);
	}

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
	DEBUG_ENTER("process_one_message req_q=%d rsp_q=%d",
			m_req_q.size(), m_rsp_q.size());

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

	DEBUG_LEAVE("process_one_message req_q=%d rsp_q=%d",
			m_req_q.size(), m_rsp_q.size());

	return ret;
}

int32_t DpiEndpointLoopbackVpi::send_req(
		const std::string		&method,
		intptr_t				id,
		IParamValMap			*params) {
	if (m_primary) {
		m_in_dpi_call++;
	}
	int32_t ret = m_peer->peer_recv_req(method, id, params);
	if (m_primary) {
		m_in_dpi_call--;
	}

	return ret;
}

int32_t DpiEndpointLoopbackVpi::peer_recv_req(
		const std::string		&method,
		intptr_t				id,
		IParamValMap			*params) {
	DEBUG_ENTER("peer_recv_req (primary=%d)", m_primary);
	if (m_primary) {

		if (m_in_dpi_call) {
			DEBUG("Note: in DPI call ; passing directly");
			recv_req(method, id, params);
		} else {
			DEBUG("Note: NOT in DPI call ; queue and toggle VPI event");
			m_req_q.push_back({method, id, params});
			m_dpi_api->toggle_vpi_ev();
		}
	} else {
		fprintf(stdout, "TODO: pass directly to foreign\n");
		recv_req(method, id, params);
	}
	DEBUG_LEAVE("peer_recv_req (primary=%d)", m_primary);
	return 0;
}

int32_t DpiEndpointLoopbackVpi::send_rsp(
		intptr_t				id,
		IParamValMap			*result,
		IParamValMap			*error) {
	if (m_primary) {
		m_in_dpi_call++;
	}
	int32_t ret = m_peer->peer_recv_rsp(id, result, error);
	if (m_primary) {
		m_in_dpi_call--;
	}
	return ret;
}

int32_t DpiEndpointLoopbackVpi::peer_recv_rsp(
		intptr_t				id,
		IParamValMap			*result,
		IParamValMap			*error) {
	DEBUG_ENTER("peer_recv_rsp (primary=%d)", m_primary);
	if (m_primary) {
		if (m_in_dpi_call) {
			DEBUG("Note: in DPI call ; passing directly");
			recv_rsp(id, result, error);
		} else {
			DEBUG("Note: NOT in DPI call ; queue and toggle VPI event");
			m_rsp_q.push_back({id, result, error});
			m_dpi_api->toggle_vpi_ev();
		}
	} else {
		DEBUG("Note: Direct invocation");
		recv_rsp(id, result, error);
	}
	DEBUG_LEAVE("peer_recv_rsp (primary=%d)", m_primary);
	return 0;
}

} /* namespace tblink_rpc_hdl */
