/*
 * EndpointServicesVpi.cpp
 *
 *  Created on: Jul 8, 2021
 *      Author: mballance
 */
#include <functional>
#include <string.h>
#include "CallbackClosureVpi.h"
#include "EndpointServicesVpi.h"
#include "InterfaceInstProxyVpi.h"
#include "MethodCallVpi.h"
#include "tblink_rpc/IInterfaceTypeBuilder.h"
#include "tblink_rpc/IParamValInt.h"
#include "glog/logging.h"

#undef EN_DEBUG_ENDPOINT_SERVICES_VPI

#ifdef EN_DEBUG_ENDPOINT_SERVICES_VPI
#define DEBUG_ENTER(fmt, ...) \
	fprintf(stdout, "--> EndpointServicesVpi::"); \
	fprintf(stdout, fmt, ##__VA_ARGS__); \
	fprintf(stdout, "\n"); \
	fflush(stdout)
#define DEBUG_LEAVE(fmt, ...) \
	fprintf(stdout, "<-- EndpointServicesVpi::"); \
	fprintf(stdout, fmt, ##__VA_ARGS__); \
	fprintf(stdout, "\n"); \
	fflush(stdout)
#define DEBUG(fmt, ...) \
	fprintf(stdout, "EndpointServicesVpi: "); \
	fprintf(stdout, fmt, ##__VA_ARGS__); \
	fprintf(stdout, "\n"); \
	fflush(stdout)
#else
#define DEBUG(fmt, ...)
#define DEBUG_ENTER(fmt, ...)
#define DEBUG_LEAVE(fmt, ...)
#endif

using namespace tblink_rpc_core;

namespace tblink_rpc_hdl {

EndpointServicesVpi::EndpointServicesVpi(vpi_api_t *vpi) :
		m_vpi(vpi), m_global(VpiHandle::mk(vpi)) {

	m_callback_id = 1;
	m_endpoint = 0;
	m_registered = true;
	m_cached_time = 0;
	m_run_until_event = 0;
	m_pending_nb_calls = 0;
	m_pending_bl_calls = 0;
	m_shutdown = false;

	register_systf();
}

EndpointServicesVpi::~EndpointServicesVpi() {
	// TODO Auto-generated destructor stub
}

void EndpointServicesVpi::init(tblink_rpc_core::IEndpoint *endpoint) {
	m_endpoint = endpoint;
}

std::vector<std::string> EndpointServicesVpi::args() {
    s_vpi_vlog_info info;
	std::vector<std::string> ret;

    m_vpi->vpi_get_vlog_info(&info);

    for (int32_t i=0; i<info.argc; i++) {
    	ret.push_back(info.argv[i]);
    }

	return ret;
}

void EndpointServicesVpi::shutdown() {
	m_vpi->vpi_control(vpiFinish, 0);
	m_shutdown = true;
}

PLI_INT32 EndpointServicesVpi::time_cb(p_cb_data cbd) {
	std::function<void(intptr_t)> *closure =
			reinterpret_cast<std::function<void(intptr_t)> *>(cbd->user_data);
	(*closure)(reinterpret_cast<intptr_t>(cbd->obj));

	delete closure;

	return 0;
}

void EndpointServicesVpi::notify_time_cb(intptr_t callback_id) {
	DEBUG_ENTER("notify_time_cb: %d", callback_id);

	// Remove the callback from the map
	std::map<intptr_t, CallbackClosureVpi *>::const_iterator it;

	if ((it=m_cb_closure_m.find(callback_id)) != m_cb_closure_m.end()) {
		m_cb_closure_m.erase(it);
	}

	m_endpoint->notify_callback(callback_id);

	post_ev();

	DEBUG_LEAVE("notify_time_cb: %d", callback_id);
}

void EndpointServicesVpi::register_systf() {
    s_vpi_systf_data tf_data;

    LOG(INFO) << "Registering system tasks";

    // pybfms_register
    tf_data.type = vpiSysFunc;
    tf_data.sysfunctype = vpiSizedFunc;
    tf_data.compiletf = 0;
    tf_data.sizetf = 0;
    tf_data.user_data = reinterpret_cast<PLI_BYTE8 *>(this);

    tf_data.tfname = "$tblink_find_iftype";
    tf_data.calltf = &system_tf<&EndpointServicesVpi::find_iftype>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_new_iftype_builder";
    tf_data.calltf = &system_tf<&EndpointServicesVpi::new_iftype_builder>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_iftype_builder_define_method";
    tf_data.calltf = &system_tf<&EndpointServicesVpi::iftype_builder_define_method>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_define_iftype";
    tf_data.calltf = &system_tf<&EndpointServicesVpi::define_iftype>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_define_ifinst";
    tf_data.calltf = &system_tf<&EndpointServicesVpi::define_ifinst>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_ifinst_call_claim";
    tf_data.calltf = &system_tf<&EndpointServicesVpi::ifinst_call_claim>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_ifinst_call_id";
    tf_data.calltf = &system_tf<&EndpointServicesVpi::ifinst_call_id>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_ifinst_call_next_ui";
    tf_data.calltf = &system_tf<&EndpointServicesVpi::ifinst_call_next_ui>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_ifinst_call_complete";
    tf_data.type = vpiSysTask;
    tf_data.calltf = &system_tf<&EndpointServicesVpi::ifinst_call_complete>;
    m_vpi->vpi_register_systf(&tf_data);

    s_cb_data cbd;
    memset(&cbd, 0, sizeof(cbd));
    cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::on_startup>;
    cbd.reason = cbStartOfSimulation;
    m_vpi->vpi_register_cb(&cbd);


}

PLI_INT32 EndpointServicesVpi::on_startup() {
	s_cb_data cbd;

   	s_vpi_time time;
    memset(&cbd, 0, sizeof(cbd));
   	memset(&time, 0, sizeof(time));
    cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::start_of_simulation>;
    cbd.reason = cbAfterDelay;
    time.type = vpiSimTime;
    cbd.time = &time;
    m_vpi->vpi_register_cb(&cbd);

    memset(&cbd, 0, sizeof(cbd));
   	memset(&time, 0, sizeof(time));
    cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    cbd.reason = cbEndOfSimulation;
    cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::end_of_simulation>;
    m_vpi->vpi_register_cb(&cbd);

	return 0;
}

PLI_INT32 EndpointServicesVpi::start_of_simulation() {

    if (!m_registered) {
    	// If nothing else has registered, go ahead
    	// and mark ourselves built and connected
    	m_endpoint->build_complete();

    	m_endpoint->connect_complete();

    	// Decide what needs to happen next
    	idle();
    } else {
    	// Need to take another spin to be sure
    	s_cb_data cbd;
    	s_vpi_time time;

    	m_registered = false;

    	memset(&cbd, 0, sizeof(cbd));
    	memset(&time, 0, sizeof(time));

    	cbd.reason = cbAfterDelay;
    	cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    	cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::start_of_simulation>;
    	time.type = vpiSimTime;
    	cbd.time = &time;
    	m_vpi->vpi_register_cb(&cbd);
    }

	return 0;
}

PLI_INT32 EndpointServicesVpi::delta() {
	idle();

	return 0;
}

PLI_INT32 EndpointServicesVpi::end_of_simulation() {

	if (m_endpoint) {
		m_endpoint->shutdown();
	}

	return 0;
}

PLI_INT32 EndpointServicesVpi::find_iftype() {
	VpiHandleSP systf_h = m_global->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	std::string type_name = args->scan()->val_str();

	systf_h->val_ptr(m_endpoint->findInterfaceType(type_name));

	return 0;
}

PLI_INT32 EndpointServicesVpi::new_iftype_builder() {
	VpiHandleSP systf_h = m_global->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	std::string type_name = args->scan()->val_str();

	systf_h->val_ptr(m_endpoint->newInterfaceTypeBuilder(type_name));

	m_registered = true;

	return 0;
}

PLI_INT32 EndpointServicesVpi::iftype_builder_define_method() {
	VpiHandleSP systf_h = m_global->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IInterfaceTypeBuilder *iftype_builder =
			args->scan()->val_ptrT<IInterfaceTypeBuilder>();
	std::string name = args->scan()->val_str();
	intptr_t id = args->scan()->val_i64();
	std::string signature = args->scan()->val_str();
	bool is_export = args->scan()->val_bool();
	bool is_blocking = args->scan()->val_bool();

	IMethodType *method_t = iftype_builder->define_method(
			name,
			id,
			signature,
			is_export,
			is_blocking);

	systf_h->val_ptr(reinterpret_cast<void *>(method_t));

	return 0;
}

PLI_INT32 EndpointServicesVpi::define_iftype() {
	VpiHandleSP systf_h = m_global->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IInterfaceTypeBuilder *iftype_builder =
			args->scan()->val_ptrT<IInterfaceTypeBuilder>();

	IInterfaceType *iftype = m_endpoint->defineInterfaceType(iftype_builder);

	systf_h->val_ptr(iftype);

	m_registered = true;

	return 0;
}

PLI_INT32 EndpointServicesVpi::define_ifinst() {
	VpiHandleSP systf_h = m_global->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	vpiHandle scope_h = m_global->vpi()->vpi_handle(vpiScope, systf_h->hndl());
	std::string inst_name = m_global->vpi()->vpi_get_str(vpiFullName, scope_h);

	IInterfaceType *iftype = args->scan()->val_ptrT<IInterfaceType>();
	// Last parameter is the event reference
	vpiHandle notify_ev = args->scan()->release();

	InterfaceInstProxyVpi *ifinst_p = new InterfaceInstProxyVpi(
			this,
			m_vpi,
			notify_ev);

	IInterfaceInst *ifinst = m_endpoint->defineInterfaceInst(
			iftype,
			inst_name,
			std::bind(
					&InterfaceInstProxyVpi::invoke_req,
					ifinst_p,
					std::placeholders::_1,
					std::placeholders::_2,
					std::placeholders::_3,
					std::placeholders::_4));

	ifinst_p->inst(ifinst);

	m_registered = true;

	// Return the proxy, since this will get passed back to us
	systf_h->val_ptr(ifinst_p);

	return 0;
}

PLI_INT32 EndpointServicesVpi::ifinst_call_claim() {
	VpiHandleSP systf_h = m_global->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	InterfaceInstProxyVpi *ifinst_p = args->scan()->val_ptrT<InterfaceInstProxyVpi>();
	VpiHandleSP params_arg = args->scan();

	IParamValVectorSP params;
	MethodCallVpi *call = ifinst_p->claim_call();

	systf_h->val_ptr(call);

	return 0;
}

PLI_INT32 EndpointServicesVpi::ifinst_call_id() {
	VpiHandleSP systf_h = m_global->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	MethodCallVpi *call = args->scan()->val_ptrT<MethodCallVpi>();

	systf_h->val_ui64(call->method_id());

	return 0;
}

PLI_INT32 EndpointServicesVpi::ifinst_call_next_ui() {
	VpiHandleSP systf_h = m_global->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	MethodCallVpi *call = args->scan()->val_ptrT<MethodCallVpi>();

	systf_h->val_ui64(
			call->nextT<IParamValInt>()->val_u());

	return 0;
}

PLI_INT32 EndpointServicesVpi::ifinst_call_complete() {
	VpiHandleSP systf_h = m_global->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	MethodCallVpi *call = args->scan()->val_ptrT<MethodCallVpi>();

	VpiHandleSP rv_h = args->scan();
	IParamValIntSP rv;

	if (rv_h) {
		fprintf(stdout, "have return\n");
		rv = m_endpoint->mkValIntS(rv_h->val_i64());
	} else {
		fprintf(stdout, "no return\n");
	}

	// Notify that the call is complete
	call->ifc()->invoke_rsp(
			call->call_id(),
			rv);

	// If the call wasn't blocking, then
	// decrement the pending nb calls
	if (!call->method()->is_blocking()) {
		dec_pending_nb_calls();
	}

	// Release the call object now that we're done with it
	delete call;

	// Now, must decide what next to do
	idle();

	return 0;
}

void EndpointServicesVpi::post_ev() {
	// We're no longer waiting for an event. It just happened
	m_run_until_event--;

	// Go wait for the next command
	idle();
}

/**
 *
 */
int32_t EndpointServicesVpi::idle() {
	int32_t ret = 0;

	if (m_shutdown) {
		// If we're in shutdown mode, don't wait for any more messages
		return ret;
	}

//	fprintf(stdout, "idle: nb_calls=%d run_until=%d\n", m_pending_nb_calls, m_run_until_event);
//	fflush(stdout);

	// Only check for new messages if we haven't already
	// been told to run until the next event
	while (m_pending_nb_calls == 0 && m_run_until_event==0 && !m_shutdown) {
		// Wait for a request
		ret = m_endpoint->await_req();
	}

	if (m_pending_nb_calls > 0 && !m_shutdown) {
		// schedule a delta and wait for completion
    	s_cb_data cbd;
    	s_vpi_time time;

    	m_registered = false;

    	memset(&cbd, 0, sizeof(cbd));
    	memset(&time, 0, sizeof(time));

    	time.type = vpiSimTime;
    	cbd.reason = cbAfterDelay;
    	cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    	cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::delta>;
    	cbd.time = &time;
    	m_vpi->vpi_register_cb(&cbd);
	}

	return ret;
}

int32_t EndpointServicesVpi::add_time_cb(
		uint64_t 		time,
		intptr_t		callback_id) {
	DEBUG_ENTER("add_time_callback");

	// Need to take another spin to be sure
	s_cb_data cbd;
	s_vpi_time vt;

	CallbackClosureVpi *closure = new CallbackClosureVpi(
			this,
			std::bind(&EndpointServicesVpi::notify_time_cb, this, std::placeholders::_1),
			callback_id);

	memset(&cbd, 0, sizeof(cbd));
	memset(&vt, 0, sizeof(vt));
	vt.type = vpiSimTime;
	vt.low = time;
	vt.high = (time >> 32);
	cbd.reason = cbAfterDelay;
	cbd.cb_rtn = &CallbackClosureVpi::callback;
	cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(closure);
	cbd.time = &vt;
	vpiHandle cb_id = m_vpi->vpi_register_cb(&cbd);

	closure->cb_h(cb_id);
	m_cb_closure_m.insert({callback_id, closure});

	DEBUG_LEAVE("add_time_callback");

	return (cb_id != 0);
}

void EndpointServicesVpi::cancel_callback(intptr_t id) {
	// TODO: find the callback id...

}

uint64_t EndpointServicesVpi::time() {
	s_vpi_time tv;
	tv.type = vpiSimTime;

	m_vpi->vpi_get_time(0, &tv);

	uint64_t ret = tv.high;
	ret <<= 32;
	ret |= tv.low;

	return ret;
}

void EndpointServicesVpi::run_until_event() {
	m_run_until_event++;
}

void EndpointServicesVpi::inc_pending_nb_calls() {
	m_pending_nb_calls++;
}

void EndpointServicesVpi::dec_pending_nb_calls() {
	m_pending_nb_calls--;
}

} /* namespace tblink_rpc_hdl */
