/*
 * ILaunch.h
 *
 *  Created on: Jul 8, 2021
 *      Author: mballance
 */

#pragma once
#include "tblink_rpc/IEndpoint.h"
#include "tblink_rpc/IEndpointServices.h"

using namespace tblink_rpc_core;

/**
 * Performs needed launch steps and returns an endpoint
 * - Don't know what type of transport will be used
 * - Don't know how the other side should be launched
 */
class ILaunch;
typedef std::unique_ptr<ILaunch> ILaunchUP;
class ILaunch {
public:

	virtual ~ILaunch() { }

	virtual IEndpoint *create_ep(
			IEndpointServices		*services) = 0;

	virtual bool launch(
			IEndpoint				*ep) = 0;

	virtual std::string last_error() = 0;

};

/*
extern "C" {
// Platform must provide this symbol
ILaunch *tblink_rpc_hdl_launcher();
}
 */
