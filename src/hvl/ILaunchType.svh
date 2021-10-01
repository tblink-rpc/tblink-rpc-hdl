
/****************************************************************************
 * ILaunchType.svh
 ****************************************************************************/

  
/**
 * Class: ILaunchType
 * 
 * TODO: Add class documentation
 */
class ILaunchType;
	
	virtual function string name();
	endfunction
	
	virtual function IEndpoint launch(
		input ILaunchParams params,
		output string		errmsg);
	endfunction
	
	virtual function ILaunchParams newLaunchParams();
	endfunction

endclass


