/*
 * VpiEndpointSequencer.cpp
 *
 *  Created on: Dec 27, 2021
 *      Author: mballance
 */
#include <functional>
#include <string.h>
#include "Debug.h"
#include "VpiEndpointSequencer.h"

#define EN_DEBUG_VPI_ENDPOINT_SEQUENCER

#ifdef EN_DEBUG_VPI_ENDPOINT_SEQUENCER
#define DEBUG_ENTER(fmt, ...) DEBUG_ENTER_BASE(VpiEndpointSequencer, fmt, ##__VA_ARGS__)
#define DEBUG_LEAVE(fmt, ...) DEBUG_LEAVE_BASE(VpiEndpointSequencer, fmt, ##__VA_ARGS__)
#define DEBUG(fmt, ...) DEBUG_BASE(VpiEndpointSequencer, fmt, ##__VA_ARGS__)
#else
#define DEBUG(fmt, ...)
#define DEBUG_ENTER(fmt, ...)
#define DEBUG_LEAVE(fmt, ...)
#endif

namespace tblink_rpc_hdl {

using namespace tblink_rpc_core;

VpiEndpointSequencer::VpiEndpointSequencer(
		vpi_api_t					*vpi,
		tblink_rpc_core::IEndpoint 	*ep) : m_vpi(vpi), m_ep(ep) {
	m_state = State::WaitIsInit;
	m_delta_cb_set = false;
	m_n_ifinsts = 0;
	m_count = 0;
	m_listener = m_ep->addListener(
			std::bind(&VpiEndpointSequencer::event,
					this,
					std::placeholders::_1));
	update_state();
}

VpiEndpointSequencer::~VpiEndpointSequencer() {
	// TODO Auto-generated destructor stub
}

void VpiEndpointSequencer::event(const tblink_rpc_core::IEndpointEvent *) {
	DEBUG_ENTER("event");
	update_state();
	DEBUG_LEAVE("event");
}

void VpiEndpointSequencer::update_state() {
	DEBUG_ENTER("update_state");
	bool wait_delta = false;
	int ret;

	switch (m_state) {
	case State::WaitIsInit: {
		DEBUG("WaitIsInit");
		if ((ret=m_ep->is_init()) != -1) {
			if (ret == 1) {
				m_state = State::WaitIfReg;
			}
			wait_delta = true;
		} else {
			fprintf(stdout, "TbLink Error: Failed during is_init\n");
			m_vpi->vpi_control(vpiFinish);
		}
	} break;
	case State::WaitIfReg: {
		int32_t n_ifinsts = m_ep->getInterfaceInsts().size();
		DEBUG("WaitIfReg: last_ifinsts=%d n_ifinsts=%d count=%d", m_n_ifinsts, n_ifinsts, m_count);

		if (m_n_ifinsts == n_ifinsts) {
			if (m_count == 16) {
				// We're really done
				if ((ret=m_ep->build_complete()) == -1) {
					fprintf(stdout, "TbLink Error: build_complete failed\n");
					m_vpi->vpi_control(vpiFinish);
				}
				m_state = State::WaitIsBuilt;
				wait_delta = (ret != -1);
			} else {
				// Try again to ensure we're stable
				m_count++;
				wait_delta = true;
			}
		} else {
			m_count = 0;
			wait_delta = true;
		}
	} break;
	case State::WaitIsBuilt: {
		DEBUG("WaitIsBuilt");
		if ((ret=m_ep->is_build_complete()) != -1) {
			if (ret == 1) {
				if ((ret=m_ep->connect_complete()) == -1) {
					fprintf(stdout, "TbLink Error: connect_complete failed\n");
					m_vpi->vpi_control(vpiFinish);
				}
				m_state = State::WaitIsConnected;
			}
			wait_delta = (ret != -1);
		} else {
			fprintf(stdout, "TbLink Error: Failed during is_build_complete\n");
			m_vpi->vpi_control(vpiFinish);
		}
	} break;
	case State::WaitIsConnected: {
		DEBUG("WaitIsConnected");
		if ((ret=m_ep->is_connect_complete()) != -1) {
			if (ret == 1) {
				m_state = State::WaitRelease;
			}
			wait_delta = true;
		} else {
			fprintf(stdout, "TbLink Error: Failed during is_connect_complete\n");
			m_vpi->vpi_control(vpiFinish);
		}
	} break;
	case State::WaitRelease: {
		DEBUG("WaitRelease");
		if (m_ep->comm_state() == IEndpoint::Released) {
			m_state = State::Released;
		} else {
			wait_delta = true;
		}
	} break;
	case State::Released: {
		DEBUG("Released");
		if (m_ep->comm_state() == IEndpoint::Waiting) {
			wait_delta = true;
			m_state = State::WaitRelease;
		}
	} break;
	}

	if (wait_delta && !m_delta_cb_set) {
		s_cb_data cbd;
		s_vpi_time vt;
		DEBUG("Setting delta");

		memset(&cbd, 0, sizeof(cbd));
		memset(&vt, 0, sizeof(vt));
		vt.type = vpiSimTime;
		cbd.reason = cbAfterDelay;
		cbd.cb_rtn = &vpi_cb<&VpiEndpointSequencer::delta>;
		cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
		cbd.time = &vt;
		vpiHandle cb_id = m_vpi->vpi_register_cb(&cbd);
		m_delta_cb_set = true;
	} else {
		DEBUG("Skip setting delta");
	}

	DEBUG_LEAVE("update_state");
}

PLI_INT32 VpiEndpointSequencer::delta() {
	DEBUG_ENTER("delta");
	m_delta_cb_set = false;
	if (m_state != State::WaitIfReg) {
		if (m_ep->process_one_message() == -1) {
			fprintf(stdout, "TbLink Error: process_one_message returned an error\n");
			m_vpi->vpi_control(vpiFinish);
		} else {
			update_state();
		}
	} else {
		update_state();
	}
	DEBUG_LEAVE("delta");
	return 0;
}

} /* namespace tblink_rpc_hdl */
