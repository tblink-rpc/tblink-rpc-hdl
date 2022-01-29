
/****************************************************************************
 * IInterfaceFactoryBase.svh
 ****************************************************************************/

  
/**
 * Class: IInterfaceFactoryBase
 * 
 * TODO: Add class documentation
 */
class IInterfaceFactoryBase;
	
	virtual function string name();
		$display("TbLink Error: IInterfaceFactoryBase::name not implemented");
		$finish(1);
		return "";
	endfunction

	virtual function IInterfaceType defineType(IEndpoint ep);
		$display("TbLink Error: IInterfaceFactoryBase::defineType not implemented");
		$finish(1);
		return null;
	endfunction
	
	virtual function tblink_rpc::IInterfaceImpl createIfImpl(
		tblink_rpc::IInterfaceInst		ifinst,
		bit								is_mirror);
		$display("TbLink Error: IInterfaceFactoryBase::createIfImpl not implemented");
		$finish(1);
		return null;
	endfunction
	


endclass


