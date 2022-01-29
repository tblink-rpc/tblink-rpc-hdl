
/****************************************************************************
 * TbLinkLaunchSeqBase.svh
 ****************************************************************************/

  
/**
 * Class: TbLinkLaunchSeqBase
 * 
 * TODO: Add class documentation
 */
class TbLinkLaunchSeqBase #(
		type REQ=uvm_sequence_item, 
		type RSP=REQ) extends uvm_sequence #(REQ, RSP);

	virtual task body();
		IInterfaceImplProxy proxy;
		IEndpoint ep;
		IInterfaceType iftype;
		IInterfaceInst ifinst;
		IInterfaceFactoryBase factory = get_factory();
		
		// TODO: Find launch type
		// TODO: Configure launcher parameters
		// TODO: Launch
		// TODO: Configure endpoint with services
		// TODO: Register type with endpoint
		
		// TODO: Create implementation and proxy for ifinst
		proxy = create_proxy();
		
		iftype = factory.defineType(ep);

		// TODO: Create ifinst on endpoint
		//       - How do we know whether it's a mirror or not?
		ep.defineInterfaceInst(
				iftype, // Need to get type
				"inst",
				proxy.is_mirror(),
				proxy);
		
	endtask
	
	virtual function IInterfaceFactoryBase get_factory();
		$display("TbLink Error: TbLinkLaunchSeqBase::get_factory unimplemented");
		$finish(1);
		return null;
	endfunction
	
	virtual function IInterfaceImplProxy create_proxy();
		$display("TbLink Error: TbLinkLaunchSeqBase::create_proxy unimplemented");
		$finish(1);
		return null;
	endfunction


endclass


