/*
 * InterfaceInstVpi.cpp
 *
 *  Created on: Jul 14, 2021
 *      Author: mballance
 */

#include "InterfaceInstProxyVpi.h"
#include "EndpointServicesVpi.h"

using namespace tblink_rpc_core;
namespace tblink_rpc_hdl {

InterfaceInstProxyVpi::InterfaceInstProxyVpi(
		EndpointServicesVpi		*services,
		vpi_api_t				*vpi,
		vpiHandle 				notify_ev) :
				m_services(services), m_vpi(vpi),
				m_notify_ev(notify_ev), m_inst(0) {
	m_ev_val = 1;
}

InterfaceInstProxyVpi::~InterfaceInstProxyVpi() {
	// TODO Auto-generated destructor stub
}

void InterfaceInstProxyVpi::invoke_req(
		tblink_rpc_core::IInterfaceInst				*inst,
		tblink_rpc_core::IMethodType				*method,
		intptr_t									call_id,
		tblink_rpc_core::IParamValVectorSP			params) {

	m_calls.push_back(MethodCallVpi::mk(
			m_inst,
			method,
			call_id,
			params));

	fprintf(stdout, "MethodCallVpi %p call_id=%lld\n", m_calls.back().get(), call_id);

    s_vpi_value val;

    fprintf(stdout, "invoke_req\n");
    fflush(stdout);

    val.format = vpiIntVal;
    val.value.integer = (m_ev_val & 1);
    m_ev_val++;

    // Signal an event to cause the BFM to wake up
    m_vpi->vpi_put_value(m_notify_ev, &val, 0, vpiNoDelay);

    if (!method->is_blocking()) {
    	// TODO: notify 'services' that we need to spin
    	// by a delta
    	m_services->inc_pending_nb_calls();
    }
}

MethodCallVpi *InterfaceInstProxyVpi::claim_call() {
	MethodCallVpi *ret = 0;
	if (m_calls.size() > 0) {
		ret = m_calls.at(0).release();
		m_calls.erase(m_calls.begin());
	}

	return ret;
}

} /* namespace tblink_rpc_hdl */
