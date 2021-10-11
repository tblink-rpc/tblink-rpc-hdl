/****************************************************************************
 * loopback_smoke_bfm_impl.svh
 ****************************************************************************/

/**
 * Class: loopback_smoke_bfm_impl
 * 
 * TODO: Add class documentation
 */
class loopback_smoke_bfm_impl #(type T=IInterfaceImpl) extends IInterfaceImpl;
	IInterfaceInst		m_ifinst;
	T					m_impl;
	IMethodType			m_inc;
	
	function new(IInterfaceInst ifinst, T impl);
		IInterfaceType iftype = ifinst.iftype();
		m_ifinst = ifinst;
		m_impl = impl;
		
		m_inc = iftype.findMethod("inc");
	endfunction
	
	function void inc();
		IParamValVec params;
		$display("TODO: inc");
		$display("--> invoke");
		void'(m_ifinst.invoke_nb(
					m_inc,
					params));
		$display("<-- invoke");
				
	endfunction
	
	virtual function IParamVal invoke_nb(
		input IInterfaceInst		ifinst,
		input IMethodType			method,
		input IParamValVec			params);
		/*
		IParamVal retval = ifinst.mkValIntS(0, 32);
		IMethodType method_t = ii.method();
		 */
		longint id = method.id();
		
		case (id) 
			0: begin
				m_impl.inc();
			end
			default: begin
				$display("TbLink Error: unknown method %0d", id);
			end
		endcase

	endfunction
		
	virtual task invoke_b(
		output IParamVal		retval,
		input IInterfaceInst	ifinst,
		input IMethodType		method,
		input IParamValVec		params);
		retval = null;
	endtask
	
endclass

function automatic IInterfaceType loopback_smoke_bfm_define_type(IEndpoint ep);
	IInterfaceType iftype;
		
	iftype = ep.findInterfaceType(string'("target"));
		
	if (iftype == null) begin
		IInterfaceTypeBuilder iftype_b = ep.newInterfaceTypeBuilder(
				string'("target"));
		IMethodTypeBuilder mtb = iftype_b.newMethodTypeBuilder(
				string'("inc"),
				0, // id
				iftype_b.mkTypeInt(1, 32),
				1, // Export from the perspective of the BFM
				0);
		IMethodType mt;

		mt = iftype_b.add_method(mtb);

		iftype = ep.defineInterfaceType(iftype_b);
	end
		
	return iftype;	
endfunction