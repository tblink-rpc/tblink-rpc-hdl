/****************************************************************************
 * IInterfaceFactory.svh
 ****************************************************************************/

typedef class TbLink;
  
/**
 * Class: IInterfaceFactory
 * 
 * TODO: Add class documentation
 */
class IInterfaceFactory #(type T) extends IInterfaceFactoryBase;
	
	static T				m_inst = inst();

	static function T inst();
		if (m_inst == null) begin
			TbLink tblink = TbLink::inst();
			m_inst = new();
			tblink.addIfFactory(m_inst);
		end
		$display("m_inst: %p", m_inst);
		return m_inst;
	endfunction
	
endclass


