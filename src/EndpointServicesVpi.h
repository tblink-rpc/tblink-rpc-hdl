/*
 * EndpointServicesVpi.h
 *
 *  Created on: Jul 8, 2021
 *      Author: mballance
 */

#pragma once
#include <memory>
#include "vpi_api.h"
#include "tblink_rpc/IEndpoint.h"
#include "tblink_rpc/IEndpointServices.h"
#include "VpiHandle.h"

namespace tblink_rpc_hdl {

class EndpointServicesVpi;
typedef std::unique_ptr<EndpointServicesVpi> EndpointServicesVpiUP;
class EndpointServicesVpi : public tblink_rpc_core::IEndpointServices {
public:
	EndpointServicesVpi(vpi_api_t *vpi);

	virtual ~EndpointServicesVpi();

	virtual void init(tblink_rpc_core::IEndpoint *endpoint) override;

	/**
	 * Return command-line arguments.
	 */
	virtual std::vector<std::string> args() override;

	virtual void shutdown() override;

	virtual intptr_t add_time_cb(
			uint64_t 		time,
			intptr_t		callback_id) override;

	virtual void cancel_callback(intptr_t id) override;

private:

	static PLI_INT32 time_cb(p_cb_data cbd);

	void notify_time_cb(intptr_t callback_id);

	void register_systf();

	template <PLI_INT32 (EndpointServicesVpi::*M)()> static PLI_INT32 system_tf(PLI_BYTE8 *ud) {
		EndpointServicesVpi *this_p = reinterpret_cast<EndpointServicesVpi *>(ud);
		return (this_p->*M)();
	}

	PLI_INT32 find_iftype();

	PLI_INT32 new_iftype_builder();

	PLI_INT32 iftype_builder_define_method();

	PLI_INT32 define_iftype();

	PLI_INT32 define_ifinst();

	PLI_INT32 ifinst_call_claim();

	PLI_INT32 ifinst_call_complete();

private:
	vpi_api_t						*m_vpi;
	VpiHandleSP						m_global;
	intptr_t						m_callback_id;
	tblink_rpc_core::IEndpoint		*m_endpoint;

};

} /* namespace tblink_rpc_hdl */

