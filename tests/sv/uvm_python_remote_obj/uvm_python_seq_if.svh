
// Type
// - import body
// - export doit1
// - export doit2

typedef class uvm_python_obj_proxy;
typedef class uvm_python_obj_factory;

class uvm_python_obj_null #(type Tbase=uvm_object) extends Tbase;
	// Implements placeholders for Type export methods

	typedef uvm_python_obj_proxy #(uvm_python_obj_null) proxy_t;
	proxy_t				m_proxy;
	
	function new(string name="uvm_python_obj_null");
		super.new(name);
	endfunction
	
	virtual function void init(proxy_t proxy);
		m_proxy = proxy;
	endfunction
	
	virtual function void set_proxy(proxy_t proxy);
		m_proxy = proxy;
	endfunction
	
	virtual function int unsigned add(int unsigned a, int unsigned b);
		return m_proxy.add(a, b);
	endfunction
	
endclass

class uvm_python_obj_proxy #(type T=uvm_python_obj_null) extends tblink_rpc::IInterfaceImplProxy;

	typedef uvm_python_obj_factory	IfFactT;
	typedef T						ImplT;
	
	tblink_rpc::IInterfaceInst	m_ifinst;
	ImplT						m_impl;
	IMethodType					m_method_t_add;
	
	function new(T impl=null);
		if (impl == null) begin
			m_impl = new();
		end else begin
			m_impl = impl;
		end
		m_impl.set_proxy(this);
	endfunction
	
	virtual function void init(tblink_rpc::IInterfaceInst ifinst);
		m_ifinst = ifinst;
		
		// Lookup method-type handles
		begin
			IInterfaceType iftype = ifinst.iftype();
			if ((m_method_t_add=iftype.findMethod("add")) == null) begin
				`uvm_fatal("uvm_python_obj_proxy", "Failed to find method 'add'");
				return;
			end
		end
	endfunction
	
	virtual function int unsigned add(int unsigned a, int unsigned b);
		IParamVal rv_t;
		IParamValInt rv_ti;
		int unsigned rv;
		IParamValVec params = m_ifinst.mkValVec();
		
		params.push_back(m_ifinst.mkValIntU(a, 32));
		params.push_back(m_ifinst.mkValIntU(b, 32));
		
		rv_t = m_ifinst.invoke_nb(
				m_method_t_add,
				params);
		
		$cast(rv_ti, rv_t);
		rv = rv_ti.val_u();
		
		// TODO: dispose
	
		return rv;
	endfunction
	
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
			default:
				$display("TbLink Error: unknown method id %0d", method.id());
		endcase
	endtask	
	
endclass

typedef class uvm_python_obj_proxy_m;

class uvm_python_obj_m_null;
	
	typedef uvm_python_obj_proxy_m #(uvm_python_obj_m_null) proxy_t;
	proxy_t							m_proxy;
	
	function void init(proxy_t proxy);
		m_proxy = proxy;
	endfunction
	
	virtual task body();
		$display("TbLink Error: uvm_python_obj_m_null::body not implemented");
		$finish(1);
	endtask
	
endclass

class uvm_python_obj_proxy_m #(type T=uvm_python_obj_m_null) extends tblink_rpc::IInterfaceImplProxy;
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

class uvm_python_obj_factory extends InterfaceTypeRgy #(
		uvm_python_obj_factory, 
		"uvm_python_obj",
		InterfaceImplFactoryBase #(uvm_python_obj_proxy #(uvm_python_obj_null)),
		InterfaceImplFactoryBase #(uvm_python_obj_proxy_m #(uvm_python_obj_m_null)));
	
	virtual function tblink_rpc::IInterfaceType defineType(tblink_rpc::IEndpoint ep);
		tblink_rpc::IInterfaceType iftype = ep.findInterfaceType(name());
		$display("defineType for uvm_python_obj");
		
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
			
			mt_b = iftype_b.newMethodTypeBuilder(
					"add",
					2, // id
					iftype_b.mkTypeInt(0, 32),
					0,
					0);
			mt_b.add_param("a", iftype_b.mkTypeInt(0, 32));
			mt_b.add_param("b", iftype_b.mkTypeInt(0, 32));
			void'(iftype_b.add_method(mt_b));
			
			iftype = ep.defineInterfaceType(
					iftype_b,
					getImplFactory(),
					getMirrorImplFactory());
		end
		
		return iftype;
	endfunction
endclass

