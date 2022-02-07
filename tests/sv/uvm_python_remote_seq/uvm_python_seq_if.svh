
// Type
// - import body
// - export doit1
// - export doit2

typedef class uvm_python_seq_proxy;

class uvm_python_seq_null;
	// Implements placeholders for Type export methods

	typedef uvm_python_seq_proxy #(uvm_python_seq_null) proxy_t;
	proxy_t				m_proxy;
	
	virtual function void init(proxy_t proxy);
		m_proxy = proxy;
	endfunction
	
	virtual task doit(int a);
		$display("TbLink Error: uvm_python_seq::doit1 not implemented");
		$finish();
	endtask
	
	virtual task doit2(int a);
		$display("TbLink Error: uvm_python_seq::doit2 not implemented");
		$finish();
	endtask
	
endclass

class uvm_python_seq_proxy #(type T=uvm_python_seq_null) extends tblink_rpc::IInterfaceImplProxy;
	tblink_rpc::IInterfaceInst	m_ifinst;
	T							m_impl;
	
	function new(uvm_void impl=null);
		if (impl == null) begin
			m_impl = new();
		end else begin
			if (!$cast(m_impl, impl)) begin
				$display("TbLink Error: cannot cast");
			end
		end
		m_impl.init(this);
	endfunction
	
	virtual function void init(tblink_rpc::IInterfaceInst ifinst);
		m_ifinst = ifinst;
	endfunction
	
	virtual function bit is_mirror();
		return 0;
	endfunction
	
	virtual task body();
		// TOOD: pack up params (none) 
			
	endtask
	
	virtual function IParamVal invoke_nb(
		input IInterfaceInst	ifinst,
		input IMethodType		method,
		input IParamValVec		params);
		// TODO: Decode and dispatch
		$display("Error: invoke_nb not overridden");
		$finish();
		return null;
	endfunction

	virtual task invoke_b(
		output IParamVal		retval,
		input IInterfaceInst	ifinst,
		input IMethodType		method,
		IParamValVec			params);
		case (method.id())
			1: begin
				IParamVal pt;
				IParamValInt p_a;
				
				pt = params.at(0);
				if (!$cast(p_a, pt)) begin
					$display("TbLink Error: first parameter is not an Int");
					$finish();
					return;
				end
				
				m_impl.doit(
						p_a.val_s()
					);
			end
			default:
				$display("TbLink Error: unknown method id %0d", method.id());
		endcase
	endtask	
	
endclass

typedef class uvm_python_seq_proxy_m;

class uvm_python_seq_m_null;
	
	typedef uvm_python_seq_proxy_m #(uvm_python_seq_m_null) proxy_t;
	proxy_t							m_proxy;
	
	function void init(proxy_t proxy);
		m_proxy = proxy;
	endfunction
	
	virtual task body();
		$display("TbLink Error: uvm_python_seq_m_null::body not implemented");
		$finish(1);
	endtask
	
endclass

class uvm_python_seq_proxy_m #(type T=uvm_python_seq_m_null) extends tblink_rpc::IInterfaceImplProxy;
	T								m_impl;
	tblink_rpc::IInterfaceInst		m_ifinst;
	
	function new(uvm_void impl=null);
		if (impl == null) begin
			m_impl = new();
		end else begin
			if (!$cast(m_impl, impl)) begin
				$display("TbLink Error: Cannot cast type");
			end
		end
		m_impl.init(this);
	endfunction
	
	virtual function void init(tblink_rpc::IInterfaceInst ifinst);
		m_ifinst = ifinst;
	endfunction
	
	virtual function bit is_mirror();
		return 1;
	endfunction
	
	virtual function IParamVal invoke_nb(
		input IInterfaceInst	ifinst,
		input IMethodType		method,
		input IParamValVec		params);
		IParamVal ret;
		
		case (method.id())
			default: begin
				$display("TbLink Error: unknown method-id %0d", method.id());
				$finish();
			end
		endcase
		return ret;
	endfunction

	virtual task invoke_b(
		output IParamVal		retval,
		input IInterfaceInst	ifinst,
		input IMethodType		method,
		IParamValVec			params);
		case (method.id())
			0: begin
				m_impl.body();
			end
			default: begin
				$display("TbLink Error: unknown method-id %0d", method.id());
				$finish();
			end
		endcase
	endtask	

endclass

class uvm_python_seq_factory extends InterfaceTypeRgy #(
		uvm_python_seq_factory, 
		"uvm_python_seq",
		InterfaceImplFactoryBase #(uvm_python_seq_proxy #(uvm_python_seq_null)),
		InterfaceImplFactoryBase #(uvm_python_seq_proxy_m #(uvm_python_seq_m_null)));
	
	virtual function tblink_rpc::IInterfaceType defineType(tblink_rpc::IEndpoint ep);
		tblink_rpc::IInterfaceType iftype = ep.findInterfaceType(name());
		$display("defineType for uvm_python_seq");
		
		if (iftype == null) begin
			tblink_rpc::IInterfaceTypeBuilder iftype_b = 
				ep.newInterfaceTypeBuilder(name());
			tblink_rpc::IMethodTypeBuilder mt_b = iftype_b.newMethodTypeBuilder(
					"body",
					0,
					null,
					0,
					1);
			void'(iftype_b.add_method(mt_b));
			
			mt_b = iftype_b.newMethodTypeBuilder(
					"doit",
					1,
					null,
					1,
					1);
			mt_b.add_param("a", iftype_b.mkTypeInt(1, 32));
			void'(iftype_b.add_method(mt_b));
			
			iftype = ep.defineInterfaceType(
					iftype_b,
					getImplFactory(),
					getMirrorImplFactory());
		end
		
		return iftype;
	endfunction
endclass

