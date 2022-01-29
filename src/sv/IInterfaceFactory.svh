
/****************************************************************************
 * IInterfaceFactory.svh
 ****************************************************************************/

  
/**
 * Class: IInterfaceFactory
 * 
 * TODO: Add class documentation
 */
class IInterfaceFactory;
	
	virtual function string name();
		$display("TbLink Error: IInterfaceFactory::name not implemented");
		$finish(1);
		return "";
	endfunction

	virtual function IInterfaceType defineType(IEndpoint ep);
		$display("TbLink Error: IInterfaceFactory::define_type not implemented");
		$finish(1);
		return null;
	endfunction
	


endclass


