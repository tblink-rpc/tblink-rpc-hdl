/*
 * TimeCallbackClosureDpi.h
 *
 *  Created on: Jul 29, 2021
 *      Author: mballance
 */

#pragma once
#include <stdint.h>
#include "vpi_api.h"

namespace tblink_rpc_hdl {

class EndpointServicesDpi;

class TimeCallbackClosureDpi {
public:
	TimeCallbackClosureDpi(
			EndpointServicesDpi			*services,
			intptr_t					callback_id
			);

	virtual ~TimeCallbackClosureDpi();

	void notify();

	static PLI_INT32 vpi_time_cb(p_cb_data cbd);

	void vpi_time_cb();

private:
	EndpointServicesDpi					*m_services;
	intptr_t							m_callback_id;

};

} /* namespace tblink_rpc_hdl */

