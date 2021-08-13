/*
 * EndpointServicesDpi.h
 *
 *  Created on: Jul 8, 2021
 *      Author: mballance
 */

#pragma once
#include <memory>
#include "dpi_api.h"
#include "tblink_rpc/IEndpointServices.h"
#include "tblink_rpc/IInterfaceInst.h"
#include "vpi_api.h"
#include "VpiHandle.h"

namespace tblink_rpc_hdl {

class EndpointServicesDpi;
typedef std::unique_ptr<EndpointServicesDpi> EndpointServicesDpiUP;
class EndpointServicesDpi : public tblink_rpc_core::IEndpointServices {
public:
	EndpointServicesDpi(
			dpi_api_t		*dpi,
			vpi_api_t		*vpi,
			bool			have_blocking_tasks
			);

	virtual ~EndpointServicesDpi();

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

	// Release the environment to run
	virtual void run_until_event() override;

	// Notify that we've hit an event
	virtual void hit_event() override;

	void idle();

	void invoke_req(
			tblink_rpc_core::IInterfaceInst			*inst,
			tblink_rpc_core::IMethodType			*method,
			intptr_t								call_id,
			tblink_rpc_core::IParamValVector		*params);

	void inc_pending_nb() { m_pending_nb++; }

	void dec_pending_nb() { m_pending_nb--; }

	uint32_t pending_nb() { return m_pending_nb; }

	/**
	 * Internal-utility version of add-callback
	 */
	void _add_time_cb(
			uint64_t								time,
			intptr_t								callback_id,
			const std::function<void(intptr_t)>		&cb);

private:

	void notify_time_cb(intptr_t callback_id);

	void build_connect_catcher();


private:
	dpi_api_t						*m_dpi;
	VpiHandleSP						m_vpi;
	tblink_rpc_core::IEndpoint		*m_endpoint;
	bool							m_have_blocking_tasks;
	bool							m_hit_event;
	bool							m_run_until_event;
	uint32_t						m_pending_nb;
	bool							m_shutdown;
	uint32_t						m_registered;
	uint32_t						m_build_connect_catcher_count;

};

} /* namespace tblink_rpc_hdl */

