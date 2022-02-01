/****************************************************************************
 * TbLinkLaunchSeq.svh
 ****************************************************************************/

  
/**
 * Class: TbLinkLaunchSeq
 * 
 * TODO: Add class documentation
 */
class TbLinkLaunchSeq #(
		type Tf,					// Type-Registry type
		type Tp,					// Proxy-class type
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
	
	virtual function IInterfaceImpl createImpl();
		Tp impl = new(this);
		return impl;
	endfunction
	
	virtual function IInterfaceType defineType(IEndpoint ep);
		IInterfaceTypeRgy rgy = InterfaceTypeRgyBase #(Tf)::inst();
		return rgy.defineType(ep);
	endfunction

endclass

//
// my_seq_proxy #(my_seq) - Class constructor accepts instance of my_seq
// 
//class my_seq extends TbLinkLaunchSeq #(uvm_python_seq_factory #(my_seq));
//	// Base now knows
//	// - How to construct the proxy
//endclass


