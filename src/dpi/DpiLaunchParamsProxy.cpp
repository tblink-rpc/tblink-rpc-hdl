/*
 * DpiLaunchParamsProxy.cpp
 *
 *  Created on: Dec 28, 2021
 *      Author: mballance
 */

#include "DpiLaunchParamsProxy.h"

namespace tblink_rpc_hdl {

DpiLaunchParamsProxy::DpiLaunchParamsProxy(dpi_api_t *api) : m_api(api) {

}

DpiLaunchParamsProxy::~DpiLaunchParamsProxy() {
	// TODO Auto-generated destructor stub
}

void DpiLaunchParamsProxy::add_arg(const std::string &arg) {
	m_api->svSetScope(m_api->get_pkg_scope());
	m_api->dlp_proxy_add_arg(
			reinterpret_cast<void *>(this),
			arg.c_str());
}

const std::vector<std::string> &DpiLaunchParamsProxy::args() const {
	return {};
}

void DpiLaunchParamsProxy::add_param(
		const std::string		&key,
		const std::string		&val) {
	m_api->svSetScope(m_api->get_pkg_scope());
	m_api->dlp_proxy_add_param(
			reinterpret_cast<void *>(this),
			key.c_str(),
			val.c_str());
}

bool DpiLaunchParamsProxy::has_param(
		const std::string		&key) {
	return false;
}

std::string DpiLaunchParamsProxy::get_param(
		const std::string		&key) {
	return "";
}

const std::map<std::string,std::string> &DpiLaunchParamsProxy::params() const {
	return {};
}

} /* namespace tblink_rpc_hdl */
