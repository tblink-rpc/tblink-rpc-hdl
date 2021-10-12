/****************************************************************************
 * smoke.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns/1ns
`endif

interface abc_i();
endinterface

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
	
	smoke_bfm u_bfm(
			.clock(clock)
		);
	
	always @(posedge clock) begin
//		$display("posedge");
		;
	end
	
endmodule


