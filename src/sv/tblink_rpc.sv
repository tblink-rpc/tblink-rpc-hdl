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
	typedef class TbLink;
	
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
	`include "IInterfaceImpl.svh"
	`include "IInterfaceImplFactory.svh"
	`include "InterfaceImplFactoryBase.svh"
	`include "IInterfaceImplProxy.svh"
	`include "IInterfaceTypeRgy.svh"
	`include "InterfaceTypeRgyBase.svh"
	`include "InterfaceTypeRgy.svh"
	`include "IEndpoint.svh"
	`include "IEndpointEvent.svh"
	`include "IEndpointListener.svh"
	`include "IEndpointServices.svh"
	`include "IEndpointServicesFactory.svh"
	
	`include "ILaunchParams.svh"
	`include "ILaunchType.svh"

	`include "ITbLinkEvent.svh"
	`include "ITbLinkListener.svh"
	
	`include "TbLinkThread.svh"

	`include "DpiTypeInt.svh"
	`include "DpiTypeMap.svh"
	`include "DpiTypeVec.svh"
	`include "DpiType.svh"
	`include "DpiParamVal.svh"
	`include "DpiInterfaceInst.svh"
	`include "DpiMethodTypeBuilder.svh"
	
	`include "DpiInterfaceTypeBuilder.svh"
	`include "DpiInterfaceType.svh"
	`include "DpiLaunchParams.svh"
	`include "DpiLaunchParamsProxy.svh"
	`include "DpiMethodType.svh"
	`include "DpiParamValBool.svh"
	`include "DpiParamValInt.svh"
	`include "DpiParamValMap.svh"
	`include "DpiParamValStr.svh"
	`include "DpiParamValVec.svh"
	`include "DpiBfmInterfaceImpl.svh"
	`include "DpiInterfaceImplFactoryProxy.svh"
	`include "DpiInterfaceImplProxy.svh"

	`include "DpiEndpointServicesProxy.svh"
	`include "DpiEndpoint.svh"
	`include "DpiEndpointEvent.svh"
	`include "DpiEndpointListenerProxy.svh"
	`include "DpiEndpointLoopbackDpi.svh"
`ifndef VERILATOR
	`include "DpiEndpointLoopbackVpi.svh"
`endif
	
	`include "DpiLaunchType.svh"

	`include "DpiTbLinkEvent.svh"
	`include "DpiTbLinkListenerProxy.svh"

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
	`include "SVEndpointSequencer.svh"
	`include "SVEndpointServices.svh"
	`include "SVEndpointServicesProxy.svh"
	`include "SVEndpointServicesFactory.svh"
	`include "SVEndpointServicesTimedCB.svh"
	`include "SVEndpointLoopback.svh"
	`include "SVLaunchTypeRegistration.svh"
	`include "SVLaunchParams.svh"
	`include "SVLaunchTypeConnectLoopback.svh"
	`include "SVLaunchTypeLoopback.svh"
	`include "SVLaunchTypeNativeLoopbackDpi.svh"
`ifndef VERILATOR
	`include "SVLaunchTypeNativeLoopbackVpi.svh"
`endif
	
	
	`include "TbLink.svh"
	
	function automatic TbLink tblink();
		TbLink _tblink;

		/**
		 * Under normal circumstances, the package should be 
		 * registered as part of package initialization. 
		 * Verilator doesn't reliably trigger package initialization
		 * so we manually call/check here
		 */
		if (!prv_tblink_init) begin
			int unsigned time_precision;
			$display("Calling init");
			if (_tblink_rpc_pkg_init(
					`ifdef VERILATOR
						0,
					`else
						1,
					`endif
					time_precision) == 0) begin
				$display("Error: failed to initialize tblink package");
			end
	
			_tblink = TbLink::inst();
			_tblink.setTimePrecision(time_precision);
			prv_tblink_init = 1;
		end else begin
			_tblink = TbLink::inst();
		end
		
		return _tblink;
	endfunction

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
	
	/**
	 * Time-based features aren't supported in Verilator
	 */
`ifndef VERILATOR
	`include "TbLinkDeltaCb.svh"
	`include "TbLinkTimedCb.svh"
`endif /* ifndef VERILATOR */
	`include "TbLinkInvokeB.svh"

	/**
	 * Called to start TbLink's main thread. This must be called
	 * at least once from the testbench
	 */
	task automatic tblink_rpc_start();
		TbLink tblink;
		$display("--> tblink_rpc_start");
		tblink = TbLink::inst();
		tblink.start();
		$display("<-- tblink_rpc_start");
	endtask
	
	// IEndpoint functions

`ifdef UNDEFINED
	function automatic void tblink_rpc_invoke(
		chandle			ifinst_h,
		chandle			method_h,
		longint			call_id,
		chandle			params_h);
		DpiInterfaceInst	ifinst = new(ifinst_h);
		DpiMethodType		method = new(method_h);
		DpiParamValVec		params = new(params_h);
		
		$display("tblink_rpc_invoke: params_h=%p", params_h);
	
		if (method.is_blocking() != 0) begin
			TbLink tblink = TbLink::inst();
			IParamVal params_val_c;
			IParamValVec params_c;
			TbLinkInvokeB	invoke_t;
			
`ifndef VERILATOR
			if (!tblink.m_dispatcher_running) begin
				$display("TbLink Warning: Attempting to schedule a call before dispatcher is running");
			end
`endif
			
			params_val_c = params.clone();
			$cast(params_c, params_val_c);
			
			// Invoke indirectly
			invoke_t = new(
					ifinst,
					method,
					call_id,
					params_c);
			
			// Know this never blocks
			tblink.queue_thread(invoke_t);
		end else begin
			// Invoke directly
			IInterfaceImpl ifimpl = ifinst.get_impl();
			IParamVal retval;
			
			retval = ifimpl.invoke_nb(
					ifinst,
					method,
					params);
		
			ifinst.invoke_rsp(call_id, retval);
		end
	endfunction
	export "DPI-C" function tblink_rpc_invoke;
`endif

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

