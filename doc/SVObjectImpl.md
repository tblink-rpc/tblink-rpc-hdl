
There are several key aspects to SV object implementation. Some are
standard and fixed, while others are flexible but have a suggested
implementation.

# HDL: Type registration
A SV Object's interace type must be registered using a specialization
of tblink_rpc::InterfaceTypeRgy. This class implements static 
registration with the TbLink singleton. The interface type for a
specific endpoint instance is defined and registered via the 
defineType method that specializations must implement.

The class specialization must provide the following as parameters:
- Type of the factory class
- Name of the interface type being registered
- Default factory class type for non-mirror interface implementations
- Default factory class type for mirror interface implementations

# Core/HDL
The key requirement from a Core/HDL perspective is that each
interface instance have an implementation class that provides
- Function: init(ifinst)
- Task:     invoke
- Function: invoke_nb

Any class that implements this interface (IInterfaceImplProxy) can be
used as the implementation of an interface instance.

That said, it is most common to use a specific pattern of proxy-class
implementation to allow users to reuse a single proxy-class implementation
with multiple different specialization classes.

## Impl class requirements
- Function: init(proxy)
  - Allows the user class to invoke remote methods

## Use models
- Creation of an object results in the system invoking the registered factory
  - In this case, the proxy 'new' will create an instance of the impl class
- A proxy is created specifically to wrap a user class. 
  - In this case, the user will pass the implementation to the proxy 'new'

The user customizes the auto-created implementation class by registering
a new implementation factory with the appropriate type factory.


## Proxy Class(es)
The proxy decodes invocation requests for effective exports. 
It expects to call these methods on the implementation class 
(user-provided or auto-constructed). 

The proxy implements effective import tasks/functions for
effective imports. It packs arguments and calls the
appropriate invoke/invoke_nb method on the interface instance.

One proxy class for non-mirror and for mirror interface instances
shall be provided.

# Null Implementation Classes
The null implementation class exists to allow the proxy class to
be standalone without additional user content creation. This is
desirable when the interface type on the SV side only exposes
effective import methods. In this case, the user has no 
compelling reason to implement a custom implementation class.

The null implementation class provides implementations for 
any effective export methods. In the base case, these methods
must flag an unimplemented error if called.


=============================================================

Common UVM patterns
- Have a sequence type (defined API) for which we wish to run a
variety of non-SV sequences that implement/use that API

- Sequence launches a sub-environment and runs a special
entrypoint.
- Note: this doesn't actually require dynamic objects. A simple
  static instance is actually preferred here.
- Benefit, here, is the simplicity of bringing in a little bit
  of Python to be the business logic driving the UVM env backend.

** - Unclear exactly where integration code belongs...  **

-> Sequence is assumed to implement interface export API
-> Proxy is assumed to implement interface import API

- Sequence propagates several parameters to the entrypoint
  - Python class to run (must be an interface class or extended from one)
  - Current seed?
  - ???



