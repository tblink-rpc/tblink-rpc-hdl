
/****************************************************************************
 * DpiInterfaceInst.svh
 ****************************************************************************/

typedef class DpiParamValInt;

IInterfaceImpl prv_hndl2impl[chandle];

typedef class DpiEndpoint;
typedef class DpiInterfaceType;
typedef class DpiMethodType;
typedef class DpiParamValMap;
typedef class DpiParamValStr;

class DpiInterfaceInstInvokeClosure;
	chandle				m_hndl;
	IParamVal			m_retval;
	bit					m_valid;
`ifndef VERILATOR
	semaphore			m_sem = new();
`endif
	
	function new();
		m_hndl = tblink_rpc_IInterfaceInstInvokeClosure_new();
	endfunction
	
	function void dispose();
		tblink_rpc_IInterfaceInstInvokeClosure_dispose(m_hndl);
	endfunction
	
	function void response(chandle retval_h);
		m_valid = 1;
		m_retval = DpiParamVal::mk(retval_h);
`ifndef VERILATOR
		m_sem.put(1);
`endif
	endfunction
endclass

DpiInterfaceInstInvokeClosure prv_closure_m[chandle];
  
/**
 * Class: DpiInterfaceInst
 * 
 * TODO: Add class documentation
 */
class DpiInterfaceInst extends IInterfaceInst;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction

	virtual function void set_impl(IInterfaceImpl impl);
		prv_hndl2impl[m_hndl] = impl;
	endfunction
	
	virtual function IInterfaceImpl get_impl();
		return prv_hndl2impl[m_hndl];
	endfunction
	
	virtual function IInterfaceType iftype();
		chandle iftype_h = tblink_rpc_IInterfaceInst_iftype(m_hndl);
		DpiInterfaceType iftype_i = new(iftype_h);
		
		return iftype_i;
	endfunction
	
	virtual function IEndpoint endpoint();
		DpiEndpoint ep = mkDpiEndpoint(
			tblink_rpc_IInterfaceInst_endpoint(m_hndl));
		return ep;
	endfunction
	
	virtual function IParamVal invoke_nb(
		IMethodType					method,
		IParamValVec				params);
		DpiInterfaceInstInvokeClosure	closure = new();
		DpiMethodType method_dpi;
		chandle params_h;

		$display("Add %0p to map", closure.m_hndl);
		prv_closure_m[closure.m_hndl] = closure;
		
		$cast(method_dpi, method);
		params_h = DpiParamVal::getHndl(params);
	
		$display("m_hndl=%0p method_h=%0p params_h=%0p closure_h=%0p",
				m_hndl, method_dpi.m_hndl, params_h,
				closure.m_hndl);
		void'(tblink_rpc_IInterfaceInst_invoke(
				m_hndl,
				method_dpi.m_hndl,
				params_h,
				closure.m_hndl));

		if (!closure.m_valid) begin
			chandle ep_h = tblink_rpc_IInterfaceInst_endpoint(m_hndl);
			while (!closure.m_valid) begin
				if (tblink_rpc_IEndpoint_process_one_message(ep_h) == -1) begin
					break;
				end
			end
		end
		
		// Expect closure to have been invoked
		$display("Remove %0p from map", closure.m_hndl);
		prv_closure_m.delete(closure.m_hndl);
		closure.dispose();
	
		return closure.m_retval;
	endfunction
	
	virtual task invoke_b(
		output IParamVal			retval,
		input  IMethodType			method,
		input  IParamValVec			params);
		DpiInterfaceInstInvokeClosure	closure = new();
		DpiMethodType method_dpi;
		chandle params_h;

		$display("Add %0p to map", closure.m_hndl);
		prv_closure_m[closure.m_hndl] = closure;
		
		$cast(method_dpi, method);
		params_h = DpiParamVal::getHndl(params);
	
		$display("m_hndl=%0p method_h=%0p params_h=%0p closure_h=%0p",
				m_hndl, method_dpi.m_hndl, params_h,
				closure.m_hndl);
		void'(tblink_rpc_IInterfaceInst_invoke(
					m_hndl,
					method_dpi.m_hndl,
					params_h,
					closure.m_hndl));

`ifndef VERILATOR
		$display("--> m_sem.get()");
		closure.m_sem.get(1);
		$display("<-- m_sem.get()");
`else
		if (!closure.m_valid) begin
			chandle ep_h = tblink_rpc_IInterfaceInst_endpoint(m_hndl);
			while (!closure.m_valid) begin
				if (tblink_rpc_IEndpoint_process_one_message(ep_h) == -1) begin
					break;
				end
			end
		end
`endif

		// Expect closure to have been invoked
		$display("Remove %0p from map", closure.m_hndl);
		prv_closure_m.delete(closure.m_hndl);
		closure.dispose();
	
		retval = closure.m_retval;
	endtask
	
	virtual function void invoke_rsp(
		longint				call_id,
		IParamVal			retval);
		chandle		retval_h;
		
		retval_h = DpiParamVal::getHndl(retval);
		
		tblink_rpc_IInterfaceInst_invoke_rsp(m_hndl, call_id, retval_h);
	endfunction
		
	
	virtual function IParamValBool mkValBool(
		int unsigned		val);
	endfunction
	
	virtual function IParamValInt mkValIntS(
		longint				val,
		int 				width);
		DpiParamValInt ret;
		chandle val_h;
	        val_h = tblink_rpc_IInterfaceInst_mkValIntS(
				m_hndl,
				val,
				width);
		
		ret = new(val_h);
		
		return ret;
	endfunction
	
	virtual function IParamValInt mkValIntU(
		longint unsigned	val,
		int 				width);
		DpiParamValInt ret;
		chandle val_h;
	        val_h = tblink_rpc_IInterfaceInst_mkValIntU(
				m_hndl,
				val,
				width);
		
		ret = new(val_h);
		
		return ret;
	endfunction
	
	virtual function IParamValMap mkValMap();
		chandle val_h;
		DpiParamValMap ret;
		val_h = tblink_rpc_IInterfaceInst_mkValMap(m_hndl);
		ret = new(val_h);
		return ret;
	endfunction
	
	virtual function IParamValStr mkValStr(
		string				val);
		chandle val_h;
		DpiParamValStr ret;
		
		val_h = tblink_rpc_IInterfaceInst_mkValStr(
				m_hndl,
				val);
		ret = new(val_h);
		return ret;
	endfunction
	
	virtual function IParamValVec mkValVec();
		chandle val_v = tblink_rpc_IInterfaceInst_mkValVec(m_hndl);
		DpiParamValVec ret = new(val_v);
		return ret;
	endfunction	

endclass

/**
 * Function: tblink_rpc_invoke_rsp
 * 
 * Called by the InterfaceInst implementation (C++) to complete
 * a non-blocking invocation
 * 
 * Parameters:
 * - chandle closure 
 * - chandle retval 
 * 
 * Returns:
 *   void
 */
function automatic void tblink_rpc_closure_invoke_rsp(
		chandle			closure_h,
		chandle			retval_h);
	DpiInterfaceInstInvokeClosure closure;
	$display("tblink_rpc_closure_invoke_rsp: %0p", closure_h);
	closure = prv_closure_m[closure_h];
	closure.response(retval_h);
endfunction
export "DPI-C" function tblink_rpc_closure_invoke_rsp;

import "DPI-C" context function chandle tblink_rpc_IInterfaceInstInvokeClosure_new();
import "DPI-C" context function void tblink_rpc_IInterfaceInstInvokeClosure_dispose(
		chandle			closure);
		
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_endpoint(
		chandle			ifinst);
		
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_iftype(
		chandle			ifinst);

import "DPI-C" context function int tblink_rpc_IInterfaceInst_invoke(
		chandle			ifinst,
		chandle			method,
		chandle			params,
		chandle			closure);
import "DPI-C" context function void tblink_rpc_IInterfaceInst_invoke_rsp(
		chandle			ifinst,
		longint			call_id,
		chandle			retval);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValBool(
		chandle			ifinst,
		int unsigned	val);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValIntU(
		chandle				ifinst,
		longint unsigned	val,
		int unsigned		width);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValIntS(
		chandle				ifinst,
		longint				val,
		int unsigned		width);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValMap(
		chandle				ifinst);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValStr(
		chandle				ifinst,
		string				val);
import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_mkValVec(
		chandle				ifinst);

