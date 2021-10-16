
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
		
	task inc(output int ret, input int v);
		$display("inc %0d", v);
		ret = v+1;
	endtask
		
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
		IParamVal retval;
		longint id = method.id();
		
		case (id)
			default:
				$display("Error: unknown method id %0d", id);
		endcase
		
		return retval;
	endfunction
		
	function automatic void invoke_nb_dpi(chandle ii_h);
	endfunction
	export "DPI-C" function invoke_nb_dpi;
	
	task automatic invoke_b(
		output IParamVal		retval,
		input IInterfaceInst		ifinst,
		input IMethodType		method,
		input IParamValVec		params);
		longint id = method.id();
		
		retval = null;
		case (id)
			0: begin
				int rv;
				IParamValInt v;
				$cast(v, params.at(0));
				inc(rv, v.val_s());
				retval = ifinst.mkValIntS(rv, 32);
			end
			default:
				$display("Error: unknown method id %0d", id);
		endcase
	endtask

	task automatic invoke_b_dpi(chandle ii_h);
	endtask
	export "DPI-C" task invoke_b_dpi;
		
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
		ifinst = ep.defineInterfaceInst(
				iftype,
				inst_name,
				0,
				ifimpl);
	endfunction
	
	initial begin
		$display("interface: %m");
	end
	
endinterface
	

