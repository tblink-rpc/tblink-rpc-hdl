/****************************************************************************
 * smoke.v
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns/1ns
`endif

module target #(
		parameter INC_AMT=1)(input clock);

`ifdef IVERILOG
	event				if_ev;
`else
	reg					if_ev = 0;
`endif
	
	reg[63:0]			iftype_h;
	reg[63:0]			ifinst_h;
	reg[63:0]			tmp, tmp2, tmp3;
	
	function reg[31:0] inc(input reg[31:0] v);
		inc = v + 1;
	endfunction
	
	initial begin
		iftype_h = $tblink_find_iftype("target");
		
		if (iftype_h == 0) begin
			// Need to register the interface type
			$display("Register 'target' type");
			tmp = $tblink_new_iftype_builder("target");
			tmp2 = $tblink_iftype_builder_define_method(
					tmp,
					"inc",
					0,
					"u32(i32)",
					1,
					0);
			iftype_h = $tblink_define_iftype(tmp);
		end else begin
			$display("'target' type already registered");
		end
		
		$display("iftype_h: 0x%08h", iftype_h);
		
		ifinst_h = $tblink_define_ifinst(
				iftype_h, 
				if_ev);
		
		forever begin
			tmp = $tblink_ifinst_call_claim(
					ifinst_h,
					tmp2);
			
			$display("%m tmp=%0d", tmp);
			if (tmp != 0) begin
				tmp2 = $tblink_ifinst_call_id(tmp);
				case (tmp2)
					0: begin : inc_b
						reg[31:0] p1;
						reg[31:0] rv;
						$display("method-id 0");
						p1 = $tblink_ifinst_call_next_ui(tmp);
						rv = inc(p1);
						$tblink_ifinst_call_complete(tmp, rv);
					end
					default: begin
						$display("Error: unknown method id");
					end
				endcase
			end else begin
				$display("%m Waiting...");
				@if_ev;
			end
		end
	end
	
endmodule
  
/**
 * Module: smoke
 * 
 * TODO: Add module documentation
 */
module smoke(input clock);
	
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
	
	always @(posedge clock) begin
		$display("posedge");
	end
	
	target #(.INC(1))		t0(clock);
	target #(.INC(2))		t1(clock);


endmodule


