
/****************************************************************************
 * SVLaunchParams.svh
 ****************************************************************************/

  
/**
 * Class: SVLaunchParams
 * 
 * TODO: Add class documentation
 */
class SVLaunchParams extends ILaunchParams;
	string				m_args[$];
	string				m_params[string];

	virtual function void add_arg(string arg);
		m_args.push_back(arg);
	endfunction
	
	virtual function string_l args();
		return m_args;
	endfunction
	
	virtual function void add_param(
		string				key,
		string				val);
		m_params[key] = val;
	endfunction
	
	virtual function bit has_param(
		string				key);
		return m_params.exists(key) != 0;
	endfunction
	
	virtual function string get_param(
		string				key);
		if (m_params.exists(key) != 0) begin
			return m_params[key];
		end else begin
			return "";
		end
	endfunction
	
	virtual function string_m params();
		return m_params;
	endfunction
	


endclass


