/*
 * TestBfm1.cpp
 *
 *  Created on: Aug 6, 2021
 *      Author: mballance
 */

#include "TestBfm1.h"

namespace tblink_rpc_hdl {

TestBfm1::TestBfm1() {
	// TODO Auto-generated constructor stub

}

TestBfm1::~TestBfm1() {
	// TODO Auto-generated destructor stub
}

TEST_F(TestBfm1, smoke) {
	m_post_build_hook = [&]() {
		fprintf(stdout, "post-build hook\n");
	};

	// Runs build and connect
	init();

	for (std::vector<IInterfaceType *>::const_iterator
			it=m_endpoint->getInterfaceTypes().begin();
			it!=m_endpoint->getInterfaceTypes().end(); it++) {
		fprintf(stdout, "Type: %s\n", (*it)->name().c_str());
	}

	IInterfaceType *initiator = m_endpoint->findInterfaceType("initiator");
	ASSERT_TRUE(initiator);
	IMethodType *req = initiator->findMethod("req");
	ASSERT_TRUE(req);

	IInterfaceInst *i0 = 0;
	for (std::vector<IInterfaceInst *>::const_iterator
			it=m_endpoint->getInterfaceInsts().begin();
			it!=m_endpoint->getInterfaceInsts().end(); it++) {
		fprintf(stdout, "inst: %s\n", (*it)->name().c_str());
		std::string inst_name = "bfm_1.i0";
		if ((*it)->name().find(inst_name)+inst_name.size() == (*it)->name().size()) {
			fprintf(stdout, "Found it\n");
			i0 = (*it);
			break;
		}
	}

	ASSERT_TRUE(i0);

	i0->set_invoke_req_f([&](
			IInterfaceInst		*inst,
			IMethodType			*method,
			intptr_t			call_id,
			IParamValVec		*params
			) {
		fprintf(stdout, "invoke %s\n", method->name().c_str());
		fflush(stdout);
		inst->invoke_rsp(call_id, 0);
	});

	for (uint32_t i=1; i<16; i++) {
		IParamValVec *params = m_endpoint->mkValVec();
		params->push_back(m_endpoint->mkValIntU(i, 32));
		// TODO:
//		i0->invoke_nb(req, params);

		fprintf(stdout, "--> run_until_event\n");
		fflush(stdout);
		m_endpoint->run_until_event();
		fprintf(stdout, "<-- run_until_event\n");
		fflush(stdout);
	}

}

} /* namespace tblink_rpc_hdl */
