/*
 * VpiEndpointSequencer.h
 *
 *  Created on: Dec 27, 2021
 *      Author: mballance
 */

#pragma once
#include "vpi_api.h"
#include "tblink_rpc/IEndpoint.h"
#include "tblink_rpc/IEndpointEvent.h"

namespace tblink_rpc_hdl {

class VpiEndpointSequencer {
public:
	VpiEndpointSequencer(
			vpi_api_t					*vpi,
			tblink_rpc_core::IEndpoint 	*ep);

	virtual ~VpiEndpointSequencer();

private:
	enum class State {
		WaitIsInit,
		WaitIfReg,
		WaitIsBuilt,
		WaitIsConnected,
		WaitRelease,
		Released
	};

private:

	void event(const tblink_rpc_core::IEndpointEvent *);

	template <PLI_INT32 (VpiEndpointSequencer::*M)()> static PLI_INT32 vpi_cb(p_cb_data cbd) {
		return ((reinterpret_cast<VpiEndpointSequencer *>(cbd->user_data))->*M)();
//		return (this_p->*M)();
	}

	void update_state();

	PLI_INT32 delta();

private:
	vpi_api_t								*m_vpi;
	tblink_rpc_core::IEndpoint				*m_ep;
	tblink_rpc_core::IEndpointListener		*m_listener;
	State									m_state;
	bool									m_delta_cb_set;
	int32_t									m_n_ifinsts;
	int32_t									m_count;
};

} /* namespace tblink_rpc_hdl */

