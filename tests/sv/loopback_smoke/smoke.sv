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
	import uvm_pkg::*;
	import loopback_smoke_pkg::*;
	
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

	loopback_smoke_bfm		u_bfm(
			.clock(clock)
			);

	
	initial begin
		/*
		automatic TbLink tblink = TbLink::inst();
//		automatic IEndpoint ep = tblink.get_default_ep();
		tblink.start();
		 */
		uvm_config_db #(string)::set(
				uvm_top, 
				"*m_driver*", 
				"IInterfaceInst", 
				u_bfm.inst_name());
		
		run_test();

`ifndef VERILATOR
		# 10ns;
`endif
	end	
	
	always @(posedge clock) begin
//		$display("posedge");
		;
	end
	
endmodule


