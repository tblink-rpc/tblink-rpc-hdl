
/****************************************************************************
 * IInterfaceFactory.svh
 ****************************************************************************/

  
/**
 * Class: IInterfaceFactory
 * 
 * TODO: Add class documentation
 */
class IInterfaceFactory #(type T) extends IInterfaceFactoryBase;
	
	static T				m_inst = new();

	static function T inst();
		return m_inst;
	endfunction


endclass


