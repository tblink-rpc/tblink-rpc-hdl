
/****************************************************************************
 * TbLinkLaunchSeq.svh
 ****************************************************************************/

  
/**
 * Class: TbLinkLaunchSeq
 * 
 * TODO: Add class documentation
 */
class TbLinkLaunchSeq #(
		type Tt,
		type Tf, 
		type Tp, 
		type REQ=uvm_sequence_item, 
		type RSP=REQ) extends TbLinkLaunchSeqBase #(REQ, RSP);

	function void init();
	endfunction
	
	// IInterfaceImpl is completely empty
	// ImplBase has known constructor arguments (ifinst)
	
	// Seq needs to know:
	// - What to launch
	// - Type information to register with the EP
	// - Interface implementation
	
	virtual function IInterfaceImplProxy create_proxy();
		Tt leaf_t;
		Tp proxy;
		if (!$cast(leaf_t, this)) begin
			`uvm_fatal("TbLinkLaunchSeq", "Cannot cast 'this' to Tt");
			return null;
		end
		
		proxy = new(leaf_t);
		
		return proxy;
	endfunction
	
	virtual function IInterfaceFactoryBase get_factory();
		return IInterfaceFactory #(Tf)::inst();
	endfunction

endclass

//
// my_seq_proxy #(my_seq) - Class constructor accepts instance of my_seq
// 
//class my_seq extends TbLinkLaunchSeq #(my_seq, my_seq_t, my_seq_proxy #(my_seq));
//	// Base now knows
//	// - How to construct the proxy
//endclass


