
/****************************************************************************
 * TbLinkLaunchSeq.svh
 ****************************************************************************/

  
/**
 * Class: TbLinkLaunchSeq
 * 
 * TODO: Add class documentation
 */
class TbLinkLaunchSeq #(
		type Tf,
		type Tp,
		type REQ=uvm_sequence_item, 
		type RSP=REQ) extends TbLinkLaunchSeqBase #(REQ, RSP);
	Tp						m_proxy;
	
	virtual function void init(Tp proxy);
		m_proxy = proxy;
	endfunction
	
	// IInterfaceImpl is completely empty
	// ImplBase has known constructor arguments (ifinst)
	
	// Seq needs to know:
	// - What to launch
	// - Type information to register with the EP
	// - Interface implementation
	
	virtual function IInterfaceImplProxy create_proxy();
		IInterfaceFactoryBase f = IInterfaceFactory #(Tf)::inst();
		Tp proxy = new(this);
	
		return proxy;
	endfunction
	
	virtual function IInterfaceFactoryBase get_factory();
		return IInterfaceFactory #(Tf)::inst();
	endfunction

endclass

//
// my_seq_proxy #(my_seq) - Class constructor accepts instance of my_seq
// 
//class my_seq extends TbLinkLaunchSeq #(uvm_python_seq_factory #(my_seq));
//	// Base now knows
//	// - How to construct the proxy
//endclass


