
SystemVerilog environment integration is based on being able to 
call into the environment. Calling into the environment via
DPI is only possible from within a DPI-invoked call stack.
Consequently, we cannot directly call into DPI from a VPI-invoked
callback.

In this environment, the VPI code is assumed to be co-running 
with the simulation. Specifically, it must not be running
in its own OS thread.

Both ends of the loopback endpoint must know that they are 
running in loopback mode and, consequently, that waiting
for a message by waiting for a message-event callback is
preferred.

**Note:** This is known by virtue of being loopback endpoints.
- So, we should have specific wrapper classes for loopback EPs

# Restrictions of the SV/VPI-based integration
- Can only make task (potentially-blocking) calls
- 
