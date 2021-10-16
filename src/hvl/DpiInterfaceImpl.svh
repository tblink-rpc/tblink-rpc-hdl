
/****************************************************************************
 * DpiInterfaceImpl.svh
 ****************************************************************************/

  
/**
 * Class: DpiInterfaceImpl
 * 
 * This interface-implementation proxy deals with
 * environments that don't have support for virtual
 * interfaces. Instead, invocations are routed 
 * back through DPI.
 * 
 * Note: This is only supported with a DPI endpoint
 */
class DpiInterfaceImpl extends IInterfaceImpl;
	string				m_inst_path;

	function new(string inst_path);
		m_inst_path = inst_path;
	endfunction

	virtual function IParamVal invoke_nb(
		input IInterfaceInst	ifinst,
		input IMethodType		method,
		input IParamValVec		params);
		DpiInterfaceInst		ifinst_dpi;
		DpiMethodType			method_dpi;
		DpiParamValVec			params_dpi;
		chandle					retval_h;
		IParamVal				retval;
		
		if (!$cast(ifinst_dpi, ifinst)) begin
			$display("TbLink Error: ifinst is not a DPI instance");
			return null;
		end
		if (!$cast(method_dpi, method)) begin
			return null;
		end
		if (!$cast(params_dpi, params)) begin
			return null;
		end
		
		retval_h = tblink_rpc_invoke_nb_dpi_bfm(
				m_inst_path,
				ifinst_dpi.m_hndl,
				method_dpi.m_hndl,
				params_dpi.m_hndl);
		
		if (retval_h != null) begin
			retval = DpiParamVal::mk(retval_h);
		end

		return retval;
	endfunction

	virtual task invoke_b(
		output IParamVal		retval,
		input IInterfaceInst	ifinst,
		input IMethodType		method,
		IParamValVec			params);
		DpiInterfaceInst		ifinst_dpi;
		DpiMethodType			method_dpi;
		DpiParamValVec			params_dpi;
		chandle					retval_h;
		
		retval = null;
		
		if (!$cast(ifinst_dpi, ifinst)) begin
			$display("TbLink Error: ifinst is not a DPI instance");
			return;
		end
		if (!$cast(method_dpi, method)) begin
			return;
		end
		if (!$cast(params_dpi, params)) begin
			return;
		end
		
		tblink_rpc_invoke_b_dpi_bfm(
				m_inst_path,
				retval_h,
				ifinst_dpi.m_hndl,
				method_dpi.m_hndl,
				params_dpi.m_hndl);
		
		if (retval_h != null) begin
			retval = DpiParamVal::mk(retval_h);
		end
	endtask

endclass

import "DPI-C" context function chandle tblink_rpc_invoke_nb_dpi_bfm(
		input string			inst_path,
		input chandle			ifinst,
		input chandle			method,
		input chandle			params);
		
import "DPI-C" task tblink_rpc_invoke_b_dpi_bfm(
		input string			inst_path,
		output chandle			retval,
		input chandle			ifinst,
		input chandle			method,
		input chandle			params);

