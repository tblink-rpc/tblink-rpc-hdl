
/****************************************************************************
 * IEndpoint.svh
 ****************************************************************************/

typedef class IEndpointServices;
typedef class IEndpointListener;
  
/**
 * Class: IEndpoint
 * 
 * TODO: Add class documentation
 */
class IEndpoint;
	
	typedef enum {
		Waiting,
		Released
	} comm_state_e;
	
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
	
	virtual function void addListener(IEndpointListener l);
		$display("TbLink Error: IEndpoint::addListener not implemented");
		$finish(1);
	endfunction
	
	virtual function void removeListener(IEndpointListener l);
		$display("TbLink Error: IEndpoint::removeListener not implemented");
		$finish(1);
	endfunction
	
	virtual function int await_run_until_event();
		return -1;
	endfunction
	
	virtual function int shutdown();
		return -1;
	endfunction
	
	virtual function comm_state_e comm_state();
		$display("TbLink Error: IEndpoint::comm_state not implemented");
		$finish(1);
		return Released;
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
	
	virtual task process_one_message_b(output int ret);
		ret = -1;
	endtask
	
	virtual function void getInterfaceInsts(ref IInterfaceInst ifinsts[$]);
	endfunction

endclass


