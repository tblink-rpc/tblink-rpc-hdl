
/****************************************************************************
 * SVLaunchTypeRegistration.svh
 ****************************************************************************/

typedef class TbLink;
  
/**
 * Class: SVLaunchTypeRegistration
 * 
 * TODO: Add class documentation
 */
class SVLaunchTypeRegistration #(type T=ILaunchType);

	static function bit register();
		T inst = new();
		TbLink tblink = TbLink::inst();
		
		$display("SVLaunchTypeRegistration::register");
		tblink.registerLaunchType(inst);
		return 1;
	endfunction

endclass



