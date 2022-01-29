
/****************************************************************************
 * ITbLinkEvent.svh
 ****************************************************************************/

class TbLinkEventKind;
	typedef enum {
		AddEndpoint,
		RemEndpoint
	} _t;
endclass

typedef TbLinkEventKind::_t TbLinkEventKind_t;
  
/**
 * Class: ITbLinkEvent
 * 
 * TODO: Add class documentation
 */
class ITbLinkEvent;

	virtual function TbLinkEventKind_t kind();
		$display("TbLink Error: ITbLinkEvent::kind not implemented");
		$finish(1);
		return TbLinkEventKind::AddEndpoint;
	endfunction
	
endclass


