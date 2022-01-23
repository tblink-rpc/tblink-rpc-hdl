
/****************************************************************************
 * IEndpoint.svh
 ****************************************************************************/

typedef class IEndpointServices;
typedef class IEndpointListener;

class IEndpointFlags;
	typedef enum {
		Empty		= 0,
		Claimed 	= (1 << 0),
		LoopbackPri = (1 << 1),
		LoopbackSec = (1 << 2)
	} _t;
endclass

typedef IEndpointFlags::_t IEndpointFlags_t;
  
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
	
	typedef enum {
		Automatic,
		Explicit
	} comm_mode_e;
	
	virtual function IEndpointFlags_t getFlags();
		$display("TBLink Error: IEndpoint::getFlags unimplemented");
		$finish(1);
		return IEndpointFlags::Empty;
	endfunction
	
	virtual function void setFlag(IEndpointFlags_t f);
		$display("TBLink Error: IEndpoint::getFlags unimplemented");
		$finish(1);
	endfunction
	
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
	
	virtual function int shutdown();
		return -1;
	endfunction
	
	virtual function comm_state_e comm_state();
		$display("TbLink Error: IEndpoint::comm_state not implemented");
		$finish(1);
		return Released;
	endfunction
	
	virtual function comm_mode_e comm_mode();
		$display("TbLink Error: IEndpoint::comm_mode not implemented");
		$finish(1);
		return Automatic;
	endfunction
	
	virtual function void notify_callback(longint id);
		$display("TbLink Error: IEndpoint::notify_callback not implemented");
		$finish(1);
	endfunction
	
	virtual function string last_error();
		$display("TbLink Error: IEndpoint::comm_state not implemented");
		$finish(1);
		return "";
	endfunction
	
	virtual function IInterfaceType findInterfaceType(string name);
		$display("TbLink Error: IEndpoint::findInterfaceType not implemented");
		$finish(1);
		return null;
	endfunction
	
	virtual function IInterfaceTypeBuilder newInterfaceTypeBuilder(string name);
		$display("TbLink Error: IEndpoint::newInterfaceTypeBuilder not implemented");
		$finish(1);
		return null;
	endfunction
	
	virtual function IInterfaceType defineInterfaceType(IInterfaceTypeBuilder iftype_b);
		$display("TbLink Error: IEndpoint::defineInterfaceType not implemented");
		$finish(1);
		return null;
	endfunction
	
	virtual function IInterfaceInst defineInterfaceInst(
		IInterfaceType			iftype,
		string					inst_name,
		int unsigned			is_mirror,
		IInterfaceImpl			ifinst_impl);
		$display("TbLink Error: IEndpoint::defineInterfaceInst not implemented");
		$finish(1);
		return null;
	endfunction

	/**
	 * Process a message, returning -1 on error
	 */
	virtual function int process_one_message();
		$display("TbLink Error: IEndpoint::process_one_message not implemented");
		$finish(1);
		return -1;
	endfunction
	
	virtual task process_one_message_b(output int ret);
		$display("TbLink Error: IEndpoint::process_one_message_b not implemented");
		$finish(1);
		ret = -1;
	endtask
	
	virtual function void getInterfaceInsts(ref IInterfaceInst ifinsts[$]);
		$display("TbLink Error: IEndpoint::getInterfaceInsts not implemented");
		$finish(1);
	endfunction

endclass


