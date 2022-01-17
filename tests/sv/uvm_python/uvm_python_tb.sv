/****************************************************************************
 * uvm_python_tb.sv
 ****************************************************************************/
`include "rv_macros.svh"
  
/**
 * Module: uvm_python_tb
 * 
 * TODO: Add module documentation
 */
module uvm_python_tb(input clock);
	import uvm_pkg::*;
	import uvm_python_pkg::*;

`ifdef HAVE_HDL_CLOCKGEN
	reg clock_r = 0;
	
	initial begin
		forever begin
			#10ns;
			clock_r <= ~clock_r;
		end
	end
	
	assign clock = clock_r;
`endif
	
	`RV_WIRES(bfm2dut_, 8);
	
	rv_initiator_bfm #(
		.WIDTH    (8   )
		) u_bfm (
		.clock    (clock   ), 
		.reset    (reset   ), 
		`RV_CONNECT(i_, bfm2dut_)
		);

	initial begin
		run_test();
	end

endmodule


