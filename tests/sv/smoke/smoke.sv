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
	
	IInterfaceInst ifinst;
	
	class target extends IInterfaceImpl;
		
		virtual function void invoke_nb(input InvokeInfo ii);
			IInterfaceInst ifinst = ii.inst();
			IParamVal retval = ifinst.mkValIntS(0, 32);

			$display("target::invoke_nb");
			ii.invoke_rsp(retval);
		endfunction
		
		virtual task invoke_b(input InvokeInfo ii);
			
		endtask
	endclass
	
	target			target_inst;
	
	task init;
		begin
			// Register the API supported by this BFM instance
			automatic IEndpoint endpoint;
			automatic ILaunchType launch_t;
			automatic ILaunchParams params;
			automatic IInterfaceType target_iftype_h;
			automatic string  err;
			automatic string  python3;
			automatic TbLink  tblink = TbLink::inst();
	
			launch_t = tblink.findLaunchType(string'("process.socket"));
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
		
			params = launch_t.newLaunchParams();
			params.add_arg(python3);
			params.add_arg(string'("-m"));
			params.add_arg(string'("smoke"));
			
			endpoint = launch_t.launch(params, err);
		
			if (endpoint == null) begin
				$display("Error: cannot launch %0s", err);
				$finish();
				return;
			end

			target_iftype_h = endpoint.findInterfaceType(string'("target"));
		
			if (target_iftype_h == null) begin
				automatic IInterfaceTypeBuilder iftype_b = endpoint.newInterfaceTypeBuilder(
						string'("target"));
				automatic IMethodTypeBuilder mtb = iftype_b.newMethodTypeBuilder(
						string'("inc"),
						0,
						iftype_b.mkTypeInt(1, 32),
						1,
						0);
				automatic IMethodType mt;

				mt = iftype_b.add_method(mtb);

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
				target_iftype_h = endpoint.defineInterfaceType(iftype_b);
			end
			
			target_inst = new();

			// TODO: need to handle interface creation
			// - How do we receive callbacks?
			ifinst = endpoint.defineInterfaceInst(
					target_iftype_h,
					string'("target_inst"),
					0,
					target_inst);
		
			if (endpoint.build_complete() == -1) begin
				$display("Error: build phase failed: %0s", endpoint.last_error());
				$finish(1);
				return;
			end
		
			if (endpoint.connect_complete() == -1) begin
				$display("Error: connect phase failed: %0s", endpoint.last_error());
				$finish(1);
				return;
			end

//			tblink_rpc_IEndpoint_start(endpoint);
		
			//		tblink_rpc_run();			
		end
	endtask
	
	initial begin
		automatic TbLink tblink = TbLink::inst();
		automatic IEndpoint ep = tblink.get_default_ep();
		init();
	end	
	
	always @(posedge clock) begin
//		$display("posedge");
		;
	end
	
endmodule


