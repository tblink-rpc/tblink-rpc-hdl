
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
		return "ILaunchType::unknown";
	endfunction
	
	virtual function IEndpoint launch(
		input ILaunchParams params,
		output string		errmsg);
		return null;
	endfunction
	
	virtual function ILaunchParams newLaunchParams();
		return null;
	endfunction

endclass


