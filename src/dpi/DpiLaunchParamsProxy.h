/*
 * DpiLaunchParamsProxy.h
 *
 *  Created on: Dec 28, 2021
 *      Author: mballance
 */

#pragma once
#include "dpi_api.h"
#include "tblink_rpc/ILaunchParams.h"

namespace tblink_rpc_hdl {

class DpiLaunchParamsProxy : public tblink_rpc_core::ILaunchParams {
public:
	DpiLaunchParamsProxy(dpi_api_t *api);

	virtual ~DpiLaunchParamsProxy();

	virtual void add_arg(const std::string &arg) override;

	virtual const std::vector<std::string> &args() const override;

	virtual void add_param(
			const std::string		&key,
			const std::string		&val) override;

	virtual bool has_param(
			const std::string		&key) override;

	virtual std::string get_param(
			const std::string		&key) override;

	virtual const std::map<std::string,std::string> &params() const override;

private:
	dpi_api_t						*m_api;


};

} /* namespace tblink_rpc_hdl */

