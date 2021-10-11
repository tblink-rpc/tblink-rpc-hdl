
/****************************************************************************
 * loopback_smoke_bfm.sv
 ****************************************************************************/

  
/**
 * Module: loopback_smoke_bfm
 * 
 * TODO: Add module documentation
 */
module loopback_smoke_bfm(
		input			clock
		);
	import tblink_rpc::*;
	string m_inst_name;
	
	function string inst_name();
		return m_inst_name;
	endfunction
		
	function void inc();
		$display("inc");
	endfunction
		
	`include "loopback_smoke_bfm_impl.svh"
		
	loopback_smoke_bfm_core u_core();

	initial begin
		m_inst_name = $sformatf("%m");
		u_core.init(
				m_inst_name,
				u_core);
	end

endmodule

// Generated BFM core interface
interface loopback_smoke_bfm_core();
	import tblink_rpc::*;
	
	IInterfaceInst ifinst;
	
	typedef virtual loopback_smoke_bfm_core vif_t;
	
	function automatic IParamVal invoke_nb(
		input IInterfaceInst		ifinst,
		input IMethodType			method,
		input IParamValVec			params);
		longint id = method.id();
		
		$display("invoke_nb");
		case (id)
			0: begin
				inc();
			end
			default:
				$display("Error: unknown method id %0d", id);
		endcase
		
		return null;
	endfunction
	
	task automatic invoke_b(
		output IParamVal			retval,
		input IInterfaceInst		ifinst,
		input IMethodType			method,
		input IParamValVec			params);
		$display("invoke_b");
		retval = null;
		
	endtask
		
	function automatic void init(
			string		inst_name,
			vif_t		vif);
		TbLink    					tblink = TbLink::inst();
		IEndpoint					ep;
		IInterfaceType 				iftype;
		SVInterfaceImplVif #(vif_t) ifimpl;
		
		ep = tblink.get_default_ep();
		
		if (ep == null) begin
			$display("Error: no default endpoint");
			$finish();
		end
			
		iftype = loopback_smoke_bfm_define_type(ep);
		
		ifimpl = new(vif);
		$display("--> BFM: defineInterfaceInst");
		ifinst = ep.defineInterfaceInst(
				iftype,
				inst_name,
				0,
				ifimpl);
		$display("<-- BFM: defineInterfaceInst");
	endfunction
	
	initial begin
		$display("interface: %m");
	end
	
endinterface
	

