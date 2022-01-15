/*
 * DpiEndpointLoopbackVpi.h
 *
 *  Created on: Dec 8, 2021
 *      Author: mballance
 */

#pragma once
#include <vector>
#include "dpi_api.h"
#include "tblink_rpc/IEndpointLoopback.h"
#include "EndpointMsgBase.h"

namespace tblink_rpc_hdl {

using namespace tblink_rpc_core;

class DpiEndpointLoopbackVpi :
		public EndpointMsgBase, public virtual IEndpointLoopback {
public:
	DpiEndpointLoopbackVpi(
			dpi_api_t 					*dpi_api,
			DpiEndpointLoopbackVpi		*peer);

	virtual ~DpiEndpointLoopbackVpi();

	virtual int32_t process_one_message() override;

	virtual int32_t send_req(
			const std::string		&method,
			intptr_t				id,
			IParamValMap			*params) override;

	int32_t peer_recv_req(
			const std::string		&method,
			intptr_t				id,
			IParamValMap			*params);

	virtual int32_t send_rsp(
			intptr_t				id,
			IParamValMap			*result,
			IParamValMap			*error) override;

	int32_t peer_recv_rsp(
			intptr_t				id,
			IParamValMap			*result,
			IParamValMap			*error);

	virtual IEndpoint *peer() override { return m_peer; }

	struct Req {
		std::string		method;
		intptr_t		id;
		IParamValMap	*params;
	};

	struct Rsp {
		intptr_t		id;
		IParamValMap	*result;
		IParamValMap	*error;
	};

private:
	dpi_api_t						*m_dpi_api;
	bool							m_primary;
	int32_t							m_in_dpi_call;
	DpiEndpointLoopbackVpi			*m_peer;

	std::vector<Req>				m_req_q;
	std::vector<Rsp>				m_rsp_q;
};

} /* namespace tblink_rpc_hdl */

