
/****************************************************************************
 * SVParamValVec.svh
 ****************************************************************************/

  
/**
 * Class: SVParamValVec
 * 
 * TODO: Add class documentation
 */
class SVParamValVec extends IParamValVec;
	IParamVal				m_values[$];

	function new();

	endfunction
	
	virtual function int unsigned size();
		return m_values.size();
	endfunction
		
	virtual function IParamVal at(int unsigned idx);
		return m_values[idx];
	endfunction
		
	virtual function void push_back(IParamVal v);
		m_values.push_back(v);
	endfunction	

	virtual function kind_e kind();
		return Vec;
	endfunction
		
	virtual function IParamVal clone();
		SVParamValVec ret = new();
		
		foreach (m_values[i]) begin
			ret.push_back(m_values[i].clone());
		end
		
		return ret;
	endfunction

endclass


