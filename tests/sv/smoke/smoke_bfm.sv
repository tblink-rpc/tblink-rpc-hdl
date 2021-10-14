
/****************************************************************************
 * smoke_bfm.sv
 ****************************************************************************/

  
/**
 * Module: smoke_bfm
 * 
 * TODO: Add module documentation
 */
module smoke_bfm(
		input			clock
		);
	import tblink_rpc::*;
	string m_inst_name;
	
	function string inst_name();
		return m_inst_name;
	endfunction
		
	function int inc(int v);
		$display("inc %0d", v);
		return v+1;
	endfunction

	// Generated type-definition function
	function automatic tblink_rpc::IInterfaceType define_type(tblink_rpc::IEndpoint ep);
		tblink_rpc::IInterfaceType iftype;
		
		iftype = ep.findInterfaceType(string'("target"));
		
		if (iftype == null) begin
			tblink_rpc::IInterfaceTypeBuilder iftype_b = ep.newInterfaceTypeBuilder(
				string'("target"));
			tblink_rpc::IMethodTypeBuilder mtb = iftype_b.newMethodTypeBuilder(
				string'("inc"),
				0, // id
				iftype_b.mkTypeInt(1, 32),
				1, // Export from the perspective of the BFM
				0);
			tblink_rpc::IMethodType mt;

			mt = iftype_b.add_method(mtb);

			iftype = ep.defineInterfaceType(iftype_b);
		end
		
		return iftype;	
	endfunction
		
`ifndef VERILATOR
			
		// Generated BFM core interface
	interface smoke_bfm_core();
		import tblink_rpc::*;
		IInterfaceInst ifinst;

		typedef virtual smoke_bfm_core vif_t;
	
		function automatic IParamVal invoke_nb(
			input IInterfaceInst		ifinst,
			input IMethodType			method,
			input IParamValVec			params);
		IParamVal retval;
		longint id = method.id();
		
		$display("invoke_nb");
		case (id)
			0: begin
				int rv;
				IParamValInt v;
				$cast(v, params.at(0));
				rv = inc(v.val_s());
				retval = ifinst.mkValIntS(rv, 32);
			end
			default:
				$display("Error: unknown method id %0d", id);
		endcase
		
		return retval;
		endfunction
		
		task automatic invoke_b(
			output IParamVal			retval,
			input IInterfaceInst		ifinst,
			input IMethodType			method,
			input IParamValVec			params);
			$display("invoke_b");
			void'(inc(1));
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
			
			iftype = define_type(ep);
		
			ifimpl = new(vif);
			ifinst = ep.defineInterfaceInst(
					iftype,
					inst_name,
					0,
					ifimpl);
		endfunction
	endinterface
			
			
	smoke_bfm_core u_core();

	initial begin
		m_inst_name = $sformatf("%m");
		u_core.init(
				m_inst_name,
				u_core
				);
		tblink_rpc_start();
	end
`else // Verilator
	function automatic chandle smoke_bfm_core_invoke_nb(
			chandle	ifinst_h,
			chandle	method_h,
			chandle	params_h);
		DpiInterfaceInst ifinst = new(ifinst_h);
		DpiMethodType method = new(method_h);
		DpiParamValVec params = new(params_h);
	endfunction
	export "DPI-C" function smoke_bfm_core_invoke_nb;
		
	task automatic smoke_bfm_core_invoke_b(chandle ii_h);
	endtask
	export "DPI-C" task smoke_bfm_core_invoke_b;
		
	initial begin
		automatic TbLink   			tblink = TbLink::inst();
		automatic IEndpoint			ep;
		automatic IInterfaceType 	iftype;
		automatic DpiInterfaceImpl	ifimpl;
		automatic IInterfaceInst 	ifinst;
		
		m_inst_name = $sformatf("%m");
		
		ep = tblink.get_default_ep();
		
		if (ep == null) begin
			$display("Error: no default endpoint");
			$finish();
		end
			
		iftype = define_type(ep);
		
		ifimpl = new(m_inst_name);
		ifinst = ep.defineInterfaceInst(
				iftype,
				m_inst_name,
				0,
				ifimpl);		
		if (tblink_rpc_register_dpi_bfm(
				m_inst_name,
				"smoke_bfm_core_invoke_nb",
				"smoke_bfm_core_invoke_b") != 0) begin
			$finish(1);
		end
		tblink_rpc_start();
	end
`endif

endmodule


	

