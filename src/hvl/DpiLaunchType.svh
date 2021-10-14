/****************************************************************************
 * DpiLaunchType.svh
 ****************************************************************************/

typedef class DpiEndpoint;

/**
 * Class: DpiLaunchType
 * 
 * TODO: Add class documentation
 */
class DpiLaunchType extends ILaunchType;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction

	virtual function IEndpoint launch(
		input ILaunchParams params,
		output string		errmsg);
		DpiLaunchParams params_dpi;
		DpiEndpoint     ret;
		chandle endpoint_h;
		
		$cast(params_dpi, params);
		
		endpoint_h = tblink_rpc_ILaunchType_launch(
				m_hndl,
				params_dpi.m_hndl,
				errmsg);
		
		if (endpoint_h !=null) begin
			ret = new(endpoint_h);
		end
		
		return ret;
	endfunction
	
	virtual function ILaunchParams newLaunchParams();
		DpiLaunchParams ret;
		chandle launch_h = tblink_rpc_newLaunchParams();
		
		ret = new(launch_h);
		
		return ret;
	endfunction

endclass

import "DPI-C" context function chandle tblink_rpc_ILaunchType_launch(
		input chandle	launch,
		input chandle 	params,
		output string	error);
		
import "DPI-C" context function chandle tblink_rpc_newLaunchParams();

