import os
import sys
import socket
import time

import tblink_rpc_core
from tblink_rpc_core.endpoint_msg_transport import EndpointMsgTransport
from tblink_rpc_core.endpoint_services import EndpointServices
from tblink_rpc_core.transport_json_socket import TransportJsonSocket


class TestEndpointServices(EndpointServices):

    def init(self, ep):
        pass
    
    def args(self):
        return []
    
    def shutdown(self):
        pass
    
    def add_time_cb(self, time, callback_id) -> int:
        raise NotImplementedError("add_time_cb not implemented by class %s" % str(type(self)))
    
    def cancel_callback(self, callback_id):
        raise NotImplementedError("cancel_callback not implemented by class %s" % str(type(self)))
    
    def time(self) -> int:
        raise NotImplementedError("time not implemented by class %s" % str(type(self)))
    
    def time_precision(self) -> int:
        return -9
    
    def run_until_event(self):
        raise NotImplementedError("run_until_event not implemented by class %s" % str(type(self)))
            
    

def main():
    print("Hello from main")
    port = int(os.environ["TBLINK_PORT"])
    host = os.environ["TBLINK_HOST"]
    
    print("connect: %s:%d" % (host, port))
    
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((host, port))
    
    transport = TransportJsonSocket(sock)
    endpoint = EndpointMsgTransport(transport)
    
    endpoint.init(TestEndpointServices(), None)

    print("--> wait_init", flush=True)
    while not endpoint.is_init_complete():
        endpoint.process_one_message()
    print("<-- wait_init", flush=True)
        
    endpoint.build_complete()
    
    print("--> wait_build_complete", flush=True)
    while not endpoint.is_build_complete():
        endpoint.process_one_message()
    print("<-- wait_build_complete", flush=True)

    endpoint.connect_complete()
    
    print("--> wait_connect_complete", flush=True)
    while not endpoint.is_connect_complete():
        endpoint.process_one_message()
    print("<-- wait_connect_complete", flush=True)
    
    time.sleep(5)


if __name__ == "__main__":
    main()
    