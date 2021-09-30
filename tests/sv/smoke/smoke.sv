/****************************************************************************
 * smoke.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns/1ns
`endif

/**
 * Module: smoke
 * 
 * TODO: Add module documentation
 */
module smoke(input clock);
	import tblink_rpc::*;
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clock_r = 0;
	initial begin
		forever begin
`ifdef NEED_TIMESCALE
			#10;
`else
			#10ns;
`endif
			clock_r <= ~clock_r;
		end
	end
	assign clock = clock_r;
`endif
	
`ifdef IVERILOG
	`include "iverilog_control.svh"
`endif
	
	chandle ifinst;
	
	class target extends IInterfaceImpl;
		
		virtual function void invoke_nb(input InvokeInfo ii);
			chandle ifinst = tblink_rpc_InvokeInfo_ifinst(ii.m_hndl);
			chandle retval = tblink_rpc_IInterfaceInst_mkValIntS(ifinst, 0, 32);
			
			$display("target::invoke_nb");
			tblink_rpc_InvokeInfo_invoke_rsp(
					ii.m_hndl,
					retval);
		endfunction
		
		virtual task invoke_b(input InvokeInfo ii);
			
		endtask
	endclass
	
	target			target_inst;
	
	task init;
		begin
			// Register the API supported by this BFM instance
			automatic chandle endpoint;
			automatic chandle launch_t;
			automatic chandle params;
			automatic chandle target_iftype_h;
			automatic string  err;
			automatic string  python3;
	
			launch_t = tblink_rpc_findLaunchType("process.socket");
			if (launch_t == null) begin
				$display("Error: failed to find launch type");
				$finish();
				return;
			end
		
			if (!$value$plusargs("python3=%s", python3)) begin
				$display("Error: +python3 not specified");
				$finish();
				return;
			end
		
			params = tblink_rpc_newLaunchParams();
			tblink_rpc_ILaunchParams_add_arg(params, python3);
			tblink_rpc_ILaunchParams_add_arg(params, "-m");
			tblink_rpc_ILaunchParams_add_arg(params, "smoke");
			
			endpoint = tblink_rpc_ILaunchType_launch(launch_t, params, err);
		
			if (endpoint == null) begin
				$display("Error: cannot launch %0s", err);
				$finish();
				return;
			end

			target_iftype_h = tblink_rpc_IEndpoint_findInterfaceType(
					endpoint,
					string'("target"));
		
			if (target_iftype_h == null) begin
				automatic chandle iftype_b = tblink_rpc_IEndpoint_newInterfaceTypeBuilder(
						endpoint,
						string'("target"));
				automatic chandle mtb = tblink_rpc_IInterfaceTypeBuilder_newMethodTypeBuilder(
						iftype_b,
						"inc",
						0,
						tblink_rpc_IInterfaceTypeBuilder_mkTypeInt(iftype_b, 1, 32),
						1,
						0);
				void'(tblink_rpc_IInterfaceTypeBuilder_add_method(iftype_b, mtb));

				/*
			void'(tblink_rpc_bfm_define_method(
						iftype_b,
						string'("inc"),
						0,
						string'("u32(i32)"),
						1,
						0));
			void'(tblink_rpc_bfm_define_method(
						iftype_b,
						string'("inc_b"),
						1,
						string'("u32(i32)"),
						1,
						1));
				 */
				target_iftype_h = tblink_rpc_IEndpoint_defineInterfaceType(endpoint, iftype_b);
			end
			
			target_inst = new();

			// TODO: need to handle interface creation
			// - How do we receive callbacks?
			ifinst = tblink_rpc_IEndpoint_defineInterfaceInst(
					endpoint,
					target_iftype_h,
					"target_inst",
					0,
					target_inst);
		
			if (tblink_rpc_IEndpoint_build_complete(endpoint) == -1) begin
				$display("Error: build phase failed: %0s", 
						tblink_rpc_IEndpoint_last_error(endpoint));
				$finish(1);
				return;
			end
		
			if (tblink_rpc_IEndpoint_connect_complete(endpoint) == -1) begin
				$display("Error: connect phase failed: %0s", 
						tblink_rpc_IEndpoint_last_error(endpoint));
				$finish(1);
				return;
			end

			tblink_rpc_IEndpoint_start(endpoint);
		
			//		tblink_rpc_run();			
		end
	endtask
	
	initial begin
		TbLink tblink = TbLink::inst();
		IEndpoint ep = tblink.get_default_ep();
		init();
	end	
	
	always @(posedge clock) begin
//		$display("posedge");
		;
	end
	
endmodule


