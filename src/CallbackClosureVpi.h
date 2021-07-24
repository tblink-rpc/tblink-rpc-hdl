/*
 * CallbackClosureVpi.h
 *
 *  Created on: Jul 24, 2021
 *      Author: mballance
 */

#pragma once
#include <functional>
#include "vpi_api.h"

namespace tblink_rpc_hdl {

class CallbackClosureVpi {
public:
	CallbackClosureVpi(
			const std::function<void(intptr_t)>		&closure,
			intptr_t								callback_id
			);
	virtual ~CallbackClosureVpi();

	intptr_t callback_id() const { return m_callback_id; }

	void callback_id(intptr_t i) { m_callback_id = i; }

	vpiHandle cb_h() const { return m_cb_h; }

	void cb_h(vpiHandle h) { m_cb_h = h; }

	static PLI_INT32 callback(t_cb_data *cbd);

private:
	std::function<void(intptr_t)>	m_closure;
	intptr_t						m_callback_id;
	vpiHandle						m_cb_h;
};

} /* namespace tblink_rpc_hdl */

