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
	IInterfaceImplFactory	m_impl_factory;
	IInterfaceImplFactory	m_impl_mirror_factory;
	
	function new();
		Tf impl_f = new();
		Tfm impl_m_f = new();
		m_impl_factory = impl_f;
		m_impl_mirror_factory = impl_m_f;
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
	
endclass


