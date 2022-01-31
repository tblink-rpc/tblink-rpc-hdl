
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
		IMethodType body_m;
		
		iftype = factory.defineType(ep);
		
		body_m = iftype.findMethod("body");
		
		if (body_m == null) begin
			`uvm_fatal("TbLinkLaunchSeqBase", 
				$sformatf("Interface type %s doesn't define a 'body' method", iftype.name()));
			return;
		end
		
		// TODO: Find launch type
		// TODO: Configure launcher parameters
		// TODO: Launch
		// TODO: Configure endpoint with services
		// TODO: Register type with endpoint
		
		// TODO: Create implementation and proxy for ifinst
		proxy = create_proxy();
		

		// TODO: Create ifinst on endpoint
		//       - How do we know whether it's a mirror or not?
		ep.defineInterfaceInst(
				iftype, // Need to get type
				"inst",
				proxy.is_mirror(),
				proxy);
		
		// TODO: Complete 'build'
		
		// TODO: Complete 'connect'
		
		// TODO: Run 'body' method. 
		
		// TODO: Shutdown when complete
		
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


