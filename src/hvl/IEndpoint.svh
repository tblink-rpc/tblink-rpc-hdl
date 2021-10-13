
/****************************************************************************
 * IEndpoint.svh
 ****************************************************************************/

typedef class IEndpointServices;
  
/**
 * Class: IEndpoint
 * 
 * TODO: Add class documentation
 */
class IEndpoint;
	
	virtual function int init(
		IEndpointServices		ep_services);
		$display("TBLink Error: IEndpoint::init unimplemented");
		$finish(1);
		return -1;
	endfunction
	
	virtual function int is_init();
		$display("TBLink Error: IEndpoint::is_init unimplemented");
		$finish(1);
		return -1;
	endfunction
	
	virtual function int build_complete();
		return -1;
	endfunction
	
	virtual function int is_build_complete();
		return -1;
	endfunction
	
	virtual function int connect_complete();
		return -1;
	endfunction
	
	virtual function int is_connect_complete();
		return -1;
	endfunction
	
	virtual function int start();
		return -1;
	endfunction
	
	virtual function int shutdown();
		return -1;
	endfunction
	
	virtual function string last_error();
		return "";
	endfunction
	
	virtual function IInterfaceType findInterfaceType(string name);
		return null;
	endfunction
	
	virtual function IInterfaceTypeBuilder newInterfaceTypeBuilder(string name);
		return null;
	endfunction
	
	virtual function IInterfaceType defineInterfaceType(IInterfaceTypeBuilder iftype_b);
		return null;
	endfunction
	
	virtual function IInterfaceInst defineInterfaceInst(
		IInterfaceType			iftype,
		string					inst_name,
		int unsigned			is_mirror,
		IInterfaceImpl			ifinst_impl);
		return null;
	endfunction
	
	virtual function int process_one_message();
		return -1;
	endfunction
	
	virtual function void getInterfaceInsts(ref IInterfaceInst ifinsts[$]);
	endfunction

endclass


