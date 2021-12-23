/****************************************************************************
 * ILaunchParams.svh
 ****************************************************************************/

  
/**
 * Class: ILaunchParams
 * 
 * TODO: Add class documentation
 */
class ILaunchParams;
	
	typedef string string_l[$];
	typedef string string_m[string];

	virtual function void add_arg(string arg);
	endfunction
	
	virtual function string_l args();
		string_l ret;
		return ret;
	endfunction
	
	virtual function void add_param(
		string				key,
		string				val);
	endfunction
	
	virtual function bit has_param(
		string				key);
		return 0;
	endfunction
	
	virtual function string get_param(
		string				key);
		return "";
	endfunction
	
	virtual function string_m params();
		string_m ret;
		return ret;
	endfunction

endclass


