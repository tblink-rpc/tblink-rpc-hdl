/****************************************************************************
 * tblink.sv
 * 
 * SystemVerilog integration shim for TBLink
 ****************************************************************************/
  
/**
 * Package: tblink_rpc
 * 
 * Provides API methods that user code is intended to call.
 * Also provides a Verilator-specific implementation 
 */
package tblink_rpc;
	
	typedef class IInterfaceTypeBuilder;
	typedef class IInterfaceType;
	typedef class IInterfaceInst;
	typedef class IEndpoint;
	typedef class IInterfaceImpl;
	
	typedef class IParamVal;
	typedef class IParamValInt;
	typedef class IParamValBool;
	typedef class IParamValVec;
	`include "IParamVal.svh"
	`include "IParamValInt.svh"
	`include "IParamValMap.svh"
	`include "IParamValStr.svh"
	`include "IParamValVec.svh"
	`include "IParamValBool.svh"
	
	`include "IType.svh"
	`include "ITypeInt.svh"
	`include "ITypeMap.svh"
	`include "ITypeVec.svh"

	`include "IMethodTypeBuilder.svh"
	`include "IMethodType.svh"
	`include "IInterfaceTypeBuilder.svh"
	
	`include "IInterfaceType.svh"
	`include "IInterfaceInst.svh"
	`include "InvokeInfo.svh"
	`include "IInterfaceImpl.svh"
	`include "IEndpoint.svh"
	`include "IEndpointServices.svh"
	
	`include "ILaunchParams.svh"
	`include "ILaunchType.svh"
	

	`include "DpiTypeInt.svh"
	`include "DpiTypeMap.svh"
	`include "DpiTypeVec.svh"
	`include "DpiType.svh"
	`include "DpiInterfaceInst.svh"
	`include "DpiMethodTypeBuilder.svh"
	`include "DpiInterfaceTypeBuilder.svh"
	`include "DpiInterfaceType.svh"
	`include "DpiParamVal.svh"
	`include "DpiInvokeInfo.svh"
	`include "DpiLaunchParams.svh"
	`include "DpiLaunchType.svh"
	`include "DpiMethodType.svh"
	`include "DpiParamValBool.svh"
	`include "DpiParamValInt.svh"
	`include "DpiParamValMap.svh"
	`include "DpiParamValStr.svh"
	`include "DpiParamValVec.svh"
	`include "DpiInterfaceImpl.svh"

	`include "DpiEndpoint.svh"

	`include "SVTypeInt.svh"
	`include "SVTypeMap.svh"
	`include "SVTypeVec.svh"
	`include "SVType.svh"

	`include "SVParamVal.svh"
	`include "SVParamValBool.svh"
	`include "SVParamValInt.svh"
	`include "SVParamValMap.svh"
	`include "SVParamValStr.svh"
	`include "SVParamValVec.svh"
	
	`include "SVMethodType.svh"
	`include "SVMethodTypeBuilder.svh"
	`include "SVInterfaceImplVif.svh"
	`include "SVInterfaceInst.svh"
	`include "SVInterfaceType.svh"
	`include "SVInterfaceTypeBuilder.svh"
	`include "SVEndpoint.svh"
	`include "SVEndpointLoopback.svh"
	`include "SVLaunchTypeRegistration.svh"
	`include "SVLaunchParams.svh"
	`include "SVLaunchTypeLoopback.svh"
	
	`include "TbLink.svh"

	// Ensure that we always initialize tblink
//	TbLink _prv_tblink = TbLink::inst();

	import "DPI-C" context function chandle tblink_rpc_iftype_find_method(
			chandle		iftype_h,
			string		name);

	import "DPI-C" context function chandle _tblink_rpc_iparam_val_clone(
			chandle			hndl);
	import "DPI-C" context function int unsigned _tblink_rpc_iparam_val_type(
			chandle			hndl);
	
	import "DPI-C" context function int unsigned _tblink_rpc_iparam_val_bool_val(
			chandle			hndl);
	
	import "DPI-C" context function string tblink_rpc_IInterfaceInst_name(
			chandle			ifinst);
	import "DPI-C" context function chandle tblink_rpc_IInterfaceInst_type(
			chandle			ifinst);
	import "DPI-C" context function int unsigned tblink_rpc_IInterfaceInst_is_mirror(
			chandle			ifinst);
	
	import "DPI-C" context function chandle _tblink_rpc_ifinst_invoke_nb(
			chandle			ifinst_h,
			chandle			method_h,
			chandle			params_h);

	/**
	 * Time-based features aren't supported in Verilator
	 */
`ifndef VERILATOR
	`include "TbLinkThread.svh"
	`include "TbLinkDeltaCb.svh"
	`include "TbLinkInvokeB.svh"
	`include "TbLinkTimedCb.svh"
`endif /* ifndef VERILATOR */

	/**
	 * Called to start TbLink's main thread. This must be called
	 * at least once from the testbench
	 */
	task automatic tblink_rpc_start();
		TbLink tblink = TbLink::inst();
		tblink.start();
	endtask
	
	// IEndpoint functions
	
	function automatic void _tblink_rpc_invoke(chandle invoke_info_h);
		DpiInvokeInfo ii = new(invoke_info_h);
		IMethodType method_t = ii.method();
		
		if (method_t.is_blocking() != 0) begin
`ifndef VERILATOR
			// Invoke indirectly
			TbLinkInvokeB t = new(
					ii.inst(),
					ii.method(),
					ii.params());
			TbLink tblink = TbLink::inst();
			
			$display("Invoking Indirectly");
			// Know this never blocks
			tblink.queue_thread(t);
`else
			$display("TBLink Error: attempting to call a blocking method in Verilator");
			$finish(1);
`endif
		end else begin
			// Invoke directly
			IInterfaceInst ifinst = ii.inst();
			IInterfaceImpl ifimpl = ifinst.get_impl();
			IParamVal retval;
			
			retval = ifimpl.invoke_nb(
					ii.inst(),
					ii.method(),
					ii.params());
		
			ii.invoke_rsp(retval);
		end
	endfunction
	export "DPI-C" function _tblink_rpc_invoke;

	/**
	 * Obtain command-line arguments
	 */
	function automatic void tblink_rpc_get_plusargs(
			string prefix, 
			ref string plusargs[$]);
		chandle plusarg_v = _tblink_rpc_get_plusargs(prefix);
		DpiParamValVec plusargs_v = new(plusarg_v);
		
		if (plusarg_v == null) begin
			$display("TbLink Fatal: failed to obtain plusargs");
			$finish(1);
			return;
		end
		
		$display("tblink_rpc_get_plusargs: %0s -> %0d", 
				prefix, plusargs_v.size());
		for (int i=0; i<plusargs_v.size(); i++) begin
			DpiParamValStr arg;
			$cast(arg, plusargs_v.at(i));
			$display("Arg: %0s", arg.val());
			plusargs.push_back(arg.val());
		end
		plusargs_v.dispose();
	endfunction
	import "DPI-C" context function chandle _tblink_rpc_get_plusargs(
			string 			prefix
		);

	/**
	 * Register DPI-accessible functions that can be
	 * used to invoke methods from the endpoint. BFM
	 * registration done in this way is used to register
	 * BFMs that will be accessed via DPI
	function automatic int tblink_rpc_register_dpi_bfm(
			string					inst_path,
			string					invoke_nb_f,
			string					invoke_b_f);
		TbLink tblink = TbLink::inst();
		return _tblink_rpc_register_dpi_bfm(inst_path, invoke_nb_f, invoke_b_f);
	endfunction
	 */
	
	import "DPI-C" context function int tblink_rpc_register_dpi_bfm(
			string					inst_path,
			string					invoke_nb_f,
			string					invoke_b_f);
	
endpackage

