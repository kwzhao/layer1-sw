"""This profile allocates three bare metal nodes and connects them together via a Dell or Mellanox switch with layer1 links.

Instructions:
Click on any node in the topology and choose the `shell` menu item. When your shell window appears, use `ping` to test the link.

You will be able to ping the other node through the switch fabric. We have installed a minimal configuration on your
switches that enables the ports that are in use, and turns on spanning-tree (RSTP) in case you inadvertently created a loop with your topology. All
unused ports are disabled. The ports are in Vlan 1, which effectively gives a single broadcast domain. If you want anything fancier, you will need
to open up a shell window to your switches and configure them yourself.

If your topology has more then a single switch, and you have links between your switches, we will enable those ports too, but we do not put them into
switchport mode or bond them into a single channel, you will need to do that yourself.

If you make any changes to the switch configuration, be sure to write those changes to memory. We will wipe the switches clean and restore a default
configuration when your experiment ends."""

import geni.portal as portal
import geni.rspec.pg as pg
import geni.rspec.emulab as emulab


class GLOBALS:
    image = "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU22-64-STD"
    command = "/local/repository/setup-node.sh"


pc = portal.Context()

request = pc.makeRequestRSpec()

pc.defineParameter(
    "phystype",
    "Switch type",
    portal.ParameterType.STRING,
    "dell-s4048",
    [("mlnx-sn2410", "Mellanox SN2410"), ("dell-s4048", "Dell S4048")],
)

params = pc.bindParameters()

mysw = request.Switch("mysw")
mysw.hardware_type = params.phystype
swiface1 = mysw.addInterface()
swiface2 = mysw.addInterface()
swiface3 = mysw.addInterface()

node1 = request.RawPC("node1")
node1.hardware_type = "xl170"
node1.disk_image = GLOBALS.image
node1.addService(pg.Execute(shell="bash", command=GLOBALS.command))
iface1 = node1.addInterface()
iface1.addAddress(pg.IPv4Address("192.168.1.1", "255.255.255.0"))

node2 = request.RawPC("node2")
node2.hardware_type = "xl170"
node2.disk_image = GLOBALS.image
node2.addService(pg.Execute(shell="bash", command=GLOBALS.command))
iface2 = node2.addInterface()
iface2.addAddress(pg.IPv4Address("192.168.1.2", "255.255.255.0"))

node3 = request.RawPC("node3")
node3.hardware_type = "xl170"
node3.disk_image = GLOBALS.image
node3.addService(pg.Execute(shell="bash", command=GLOBALS.command))
iface3 = node3.addInterface()
iface3.addAddress(pg.IPv4Address("192.168.1.3", "255.255.255.0"))

link1 = request.L1Link("link1")
link1.addInterface(iface1)
link1.addInterface(swiface1)

link2 = request.L1Link("link2")
link2.addInterface(iface2)
link2.addInterface(swiface2)

link3 = request.L1Link("link3")
link3.addInterface(iface3)
link3.addInterface(swiface3)

pc.printRequestRSpec(request)
