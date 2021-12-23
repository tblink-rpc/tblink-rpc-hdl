
/****************************************************************************
 * IEndpointEvent.svh
 ****************************************************************************/

  
/**
 * Class: IEndpointEvent
 * 
 * TODO: Add class documentation
 */
class IEndpointEvent;
	
	typedef enum {
		Unknown
	} kind_t;

	virtual function kind_t kind();
		return Unknown;
	endfunction
	
endclass


