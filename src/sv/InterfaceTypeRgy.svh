/****************************************************************************
 * InterfaceTypeRgy.svh
 ****************************************************************************/

typedef class TbLink;
  
/**
 * Class: InterfaceTypeRgy
 * 
 * TODO: Add class documentation
 */
class InterfaceTypeRgy #(
		type T, 
		string Tn,
		type Tf, 
		type Tfm) extends InterfaceTypeRgyBase #(T);
	typedef InterfaceTypeRgy #(T, Tn, Tf, Tfm) this_t;
	
	typedef class ImplFactoryProxy;
	typedef class ImplMirrorFactoryProxy;
	
	IInterfaceImplFactory				m_impl_factory;
	IInterfaceImplFactory				m_impl_mirror_factory;
	ImplFactoryProxy					m_impl_factory_proxy;
	ImplMirrorFactoryProxy				m_impl_mirror_factory_proxy;
	
	function new();
		Tf impl_f = new();
		Tfm impl_m_f = new();
		
		m_impl_factory = impl_f;
		m_impl_mirror_factory = impl_m_f;
		
		m_impl_factory_proxy = new(this);
		m_impl_mirror_factory_proxy = new(this);
	endfunction
	
	virtual function string name();
		return Tn;
	endfunction
	
	virtual function tblink_rpc::IInterfaceImplFactory getImplFactory();
		return m_impl_factory;
	endfunction
	
	virtual function void setImplFactory(tblink_rpc::IInterfaceImplFactory f);
		m_impl_factory = f;
	endfunction
	
	virtual function tblink_rpc::IInterfaceImplFactory getMirrorImplFactory();
		return m_impl_mirror_factory;
	endfunction
	
	virtual function void setMirrorImplFactory(tblink_rpc::IInterfaceImplFactory f);
		m_impl_mirror_factory = f;
	endfunction	
	
	class ImplFactoryProxy extends IInterfaceImplFactory;
		this_t		m_iftype_rgy;
		
		function new(this_t iftype_rgy);
			m_iftype_rgy = iftype_rgy;
		endfunction
		
		virtual function tblink_rpc::IInterfaceImplFactory getImplFactory();
			return m_iftype_rgy.m_impl_factory;
		endfunction
	endclass

	class ImplMirrorFactoryProxy extends IInterfaceImplFactory;
		this_t		m_iftype_rgy;
		
		function new(this_t iftype_rgy);
			m_iftype_rgy = iftype_rgy;
		endfunction
		
		virtual function tblink_rpc::IInterfaceImplFactory getImplFactory();
			return m_iftype_rgy.m_impl_mirror_factory;
		endfunction
	endclass
endclass


