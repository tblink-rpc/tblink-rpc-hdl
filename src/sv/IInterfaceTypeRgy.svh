/****************************************************************************
 * IInterfaceTypeRgy.svh
 ****************************************************************************/

  
/**
 * Class: IInterfaceTypeRgy
 * 
 * TODO: Add class documentation
 */
class IInterfaceTypeRgy;
	
	virtual function string name();
		$display("TbLink Error: IInterfaceTypeRgy::name not implemented");
		$finish(1);
		return "";
	endfunction

	virtual function IInterfaceType defineType(IEndpoint ep);
		$display("TbLink Error: IInterfaceTypeRgy::defineType not implemented");
		$finish(1);
		return null;
	endfunction
	
	virtual function tblink_rpc::IInterfaceImplFactory getImplFactory();
		$display("TbLink Error: IInterfaceTypeRgy::getImplFactory not implemented");
		$finish(1);
		return null;
	endfunction
	
	virtual function void setImplFactory(tblink_rpc::IInterfaceImplFactory f);
		$display("TbLink Error: IInterfaceTypeRgy::setImplFactory not implemented");
		$finish(1);
	endfunction
	
	virtual function tblink_rpc::IInterfaceImplFactory getMirrorImplFactory();
		$display("TbLink Error: IInterfaceTypeRgy::getMirrorImplFactory not implemented");
		$finish(1);
		return null;
	endfunction
	
	virtual function void setMirrorImplFactory(tblink_rpc::IInterfaceImplFactory f);
		$display("TbLink Error: IInterfaceTypeRgy::setMirrorImplFactory not implemented");
		$finish(1);
	endfunction

endclass


