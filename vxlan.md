VTEP - perform the encapsulation/de-encapsulation
-------------------------------------------------


Frame encapsulation is done by an entity known as a VXLAN Tunnel Endpoint (VTEP). A VTEP has two logical interfaces: an uplink and a downlink. The uplink is responsible for receiving VXLAN frames and acts as a tunnel endpoint with an IP address used for routing VXLAN encapsulated frames. VTEP functionality can be implemented in software such as a virtual switch or in the form a physical switch.

VXLAN frames are sent to the IP address assigned to the destination VTEP; this IP is placed in the Outer IP DA. The IP of the VTEP sending the frame resides in the Outer IP SA.  Packets received on the uplink are mapped from the VXLAN ID to a VLAN and the Ethernet frame payload is sent as an 802.1Q Ethernet frame on the downlink.

VXLAN preserves flood and learn over an IP network using IP multicast groups. Each VXLAN ID has an assigned IP multicast group to use for traffic flooding

VTEPs are designed to be implemented as a logical device on an L2 switch. The L2 switch connects to the VTEP via a logical 802.1Q VLAN trunk.


Reference
---------

1. http://www.definethecloud.net/vxlan-deep-dive/
