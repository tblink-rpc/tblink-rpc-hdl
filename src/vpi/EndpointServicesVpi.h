/*
 * EndpointServicesVpi.h
 *
 *  Created on: Jul 8, 2021
 *      Author: mballance
 */

#pragma once
#include <map>
#include <memory>
#include "tblink_rpc/IEndpoint.h"
#include "tblink_rpc/IEndpointListener.h"
#include "tblink_rpc/IEndpointServices.h"
#include "vpi_api.h"
#include "VpiHandle.h"

namespace tblink_rpc_hdl {

class CallbackClosureVpi;

class EndpointServicesVpi;
typedef std::unique_ptr<EndpointServicesVpi> EndpointServicesVpiUP;
class EndpointServicesVpi : public tblink_rpc_core::IEndpointServices {
public:
	friend class CallbackClosureVpi;

	EndpointServicesVpi(vpi_api_t *vpi, bool is_active=false);

	virtual ~EndpointServicesVpi();

	virtual void init(tblink_rpc_core::IEndpoint *endpoint) override;

	/**
	 * Return command-line arguments.
	 */
	virtual std::vector<std::string> args() override;

	virtual void shutdown() override;

	virtual int32_t add_time_cb(
			uint64_t 		time,
			intptr_t		callback_id) override;

	virtual void cancel_callback(intptr_t id) override;

	virtual uint64_t time() override;

	virtual int32_t time_precision() override;

	virtual void run_until_event() override;

	// Notify that we've hit an event
	virtual void hit_event() override;

	void idle() override;

	void inc_pending_nb_calls();

	void dec_pending_nb_calls();

private:

	void event(const tblink_rpc_core::IEndpointEvent *ev);

	static PLI_INT32 time_cb(p_cb_data cbd);

	void notify_time_cb(intptr_t callback_id);

	template <PLI_INT32 (EndpointServicesVpi::*M)()> static PLI_INT32 system_tf(PLI_BYTE8 *ud) {
		EndpointServicesVpi *this_p = reinterpret_cast<EndpointServicesVpi *>(ud);
		return (this_p->*M)();
	}

	template <PLI_INT32 (EndpointServicesVpi::*M)()> static PLI_INT32 vpi_cb(p_cb_data cbd) {
		EndpointServicesVpi *this_p = reinterpret_cast<EndpointServicesVpi *>(cbd->user_data);
		return (this_p->*M)();
	}

	PLI_INT32 active_startup_await_registration();

	PLI_INT32 active_startup_await_is_build_complete();

	PLI_INT32 active_startup_await_is_connect_complete();

	PLI_INT32 on_startup();

	PLI_INT32 start_of_simulation();

	PLI_INT32 delta();

	PLI_INT32 end_of_simulation();

	void post_ev();


private:
	vpi_api_t									*m_vpi;
	VpiHandleSP									m_global;
	bool										m_is_active;

	int32_t										m_last_registered_ifinsts;
	int32_t										m_count;

	intptr_t									m_callback_id;
	std::map<intptr_t, CallbackClosureVpi *>	m_cb_closure_m;
	tblink_rpc_core::IEndpoint					*m_endpoint;
	bool										m_registered;
	int64_t										m_cached_time;
	int32_t										m_depth;
	int32_t										m_run_until_event;
	int32_t										m_pending_time_cbs;
	int32_t										m_pending_nb_calls;
	bool										m_shutdown;
	int32_t										m_pending_bl_calls;

};

} /* namespace tblink_rpc_hdl */

