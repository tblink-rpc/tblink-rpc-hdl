/*
 * TimeCallbackClosureDpi.h
 *
 *  Created on: Jul 29, 2021
 *      Author: mballance
 */

#pragma once
#include <functional>
#include <stdint.h>

#include "../vpi/vpi_api.h"

namespace tblink_rpc_hdl {

class EndpointServicesDpi;

class TimeCallbackClosureDpi {
public:
	TimeCallbackClosureDpi(
			EndpointServicesDpi						*services,
			intptr_t								callback_id,
			const std::function<void (intptr_t)>	&cb
			);

	virtual ~TimeCallbackClosureDpi();

	void notify();

	static PLI_INT32 vpi_time_cb(p_cb_data cbd);

private:
	EndpointServicesDpi					*m_services;
	intptr_t							m_callback_id;
	std::function<void (intptr_t)>		m_cb;

};

} /* namespace tblink_rpc_hdl */

