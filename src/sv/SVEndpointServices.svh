/****************************************************************************
 * SVEndpointServices.svh
 ****************************************************************************/

typedef class DpiParamVal;
typedef class DpiParamValStr;
typedef class DpiParamValVec;
typedef class TbLink;
typedef class SVEndpointServicesTimedCB;
  
/**
 * Class: SVEndpointServices
 * 
 * Provides a basic SV implementation of endpoint services
 */
class SVEndpointServices extends IEndpointServices;
	IEndpoint						m_ep;
	SVEndpointServicesTimedCB		m_cb_m[longint];

	function new();
	endfunction

	virtual function void init(IEndpoint ep);
		m_ep = ep;
	endfunction
		
	virtual function void args(ref string argv[$]);
		chandle vec_h = tblink_rpc_SVEndpointServices_args();
		/*
		IParamVal vec_v = DpiParamVal::mk(vec_h);
		 */
		DpiParamValVec vec;
		DpiParamValStr val;
		
		$cast(vec, DpiParamVal::mk(vec_h));
		
		argv = '{};
		for (int i=0; i<vec.size(); i++) begin
			$cast(val, vec.at(i));
			argv.push_back(val.val());
		/*
			*/
		end

		/*
		vec.dispose();
		*/
		
	endfunction
		
	virtual function void shutdown();
	endfunction
		
	virtual function int add_time_cb(
		longint unsigned			simtime,
		longint						callback_id);
		TbLink tblink = TbLink::inst();
		SVEndpointServicesTimedCB cb = new(this, simtime, callback_id);
		$display("SVEndpointServices::add_time_cb");
		m_cb_m[callback_id] = cb;
		tblink.queue_thread(cb);
		return 0;
	endfunction
	
	function void notify_time_cb(
		longint						callback_id);
		m_cb_m.delete(callback_id);
		m_ep.notify_callback(callback_id);
	endfunction
		
	virtual function void cancel_callback(
		longint						callback_id);
		SVEndpointServicesTimedCB cb = m_cb_m[callback_id];
		cb.m_valid = 0;
		m_cb_m.delete(callback_id);
	endfunction
		
	virtual function longint unsigned get_time();
		return $time;
	endfunction
		
	virtual function int time_precision();
		TbLink tblink = TbLink::inst();
		return tblink.getTimePrecision();
	endfunction
		
endclass

// Returns a ValVec of strings
import "DPI-C" context function chandle tblink_rpc_SVEndpointServices_args();


