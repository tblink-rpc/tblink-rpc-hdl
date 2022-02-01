
/****************************************************************************
 * InterfaceTypeRgyBase.svh
 ****************************************************************************/

  
/**
 * Class: InterfaceTypeRgyBase
 * 
 * TODO: Add class documentation
 */
class InterfaceTypeRgyBase #(type T) extends IInterfaceTypeRgy;

	static T				m_inst = inst();

	static function T inst();
		if (m_inst == null) begin
			TbLink tblink = TbLink::inst();
			m_inst = new();
			tblink.addIfTypeRgy(m_inst);
		end
		$display("m_inst: %p", m_inst);
		return m_inst;
	endfunction

endclass


