"""This profile uses 4 switches and 8 hosts. 
2 switches will have 4 hosts each and each switch will have 2 links to the other switch."""

# Import the Portal object.
import geni.portal as portal

# Import the ProtoGENI library.
import geni.rspec.pg as pg

# Import the Emulab specific extensions.
import geni.rspec.emulab as emulab

# Create a portal context.
pc = portal.Context()

# Create a Request object to start building the RSpec.
request = pc.makeRequestRSpec()  # simulates HTTP request

pc.defineParameter(
    "phystype1",
    "Switch 1 type",
    portal.ParameterType.STRING,
    "dell-s4048",
    [("mlnx-sn2410", "Mellanox SN2410"), ("dell-s4048", "Dell S4048")],
)

pc.defineParameter(
    "phystype2",
    "Switch 2 type",
    portal.ParameterType.STRING,
    "dell-s4048",
    [("mlnx-sn2410", "Mellanox SN2410"), ("dell-s4048", "Dell S4048")],
)

pc.defineParameter(
    "phystype3",
    "Switch 3 type",
    portal.ParameterType.STRING,
    "dell-s4048",
    [("mlnx-sn2410", "Mellanox SN2410"), ("dell-s4048", "Dell S4048")],
)

pc.defineParameter(
    "phystype4",
    "Switch 4 type",
    portal.ParameterType.STRING,
    "dell-s4048",
    [("mlnx-sn2410", "Mellanox SN2410"), ("dell-s4048", "Dell S4048")],
)

# Retrieve the values the user specifies during instantiation. Must be called exactly once.
params = pc.bindParameters()

# Do not run snmpit
# request.skipVlans()

# Create 8 hosts and assign IP addresses.
hosts = []
for i in range(1, 9):
    node = request.RawPC(f"node{i}")
    iface = node.addInterface()
    iface.addAddress(pg.IPv4Address(f"192.168.{i}.1", "255.255.255.0"))
    hosts.append((node, iface))

# Create switches and assign types.
switches = []
for i, swtype in enumerate(
    [params.phystype1, params.phystype2, params.phystype3, params.phystype4], start=1
):
    switch = request.Switch(f"mysw{i}")
    switch.hardware_type = swtype
    switches.append(switch)

# Link hosts to switches: 4 hosts to switch 2 and 4 hosts to switch 4.
for i, (node, iface) in enumerate(hosts):
    switch = switches[1]
    if i >= 4:
        switch = switches[3]
    sw_iface = switch.addInterface()
    link = request.L1Link(f"link_node{i+1}_switch{2 if i < 4 else 4}")
    link.addInterface(iface)
    link.addInterface(sw_iface)

# Create trunk links between switches.
trunk_links = [
    (0, 1),  # Switch 1 to Switch 2
    (1, 2),  # Switch 2 to Switch 3
    (2, 3),  # Switch 3 to Switch 4
    (3, 0),  # Switch 4 to Switch 1
]

for i, (sw1_idx, sw2_idx) in enumerate(trunk_links):
    sw1_iface = switches[sw1_idx].addInterface()
    sw2_iface = switches[sw2_idx].addInterface()
    trunk = request.L1Link(f"trunk{i+1}")
    trunk.addInterface(sw1_iface)
    trunk.addInterface(sw2_iface)

# Print the RSpec to the enclosing page.
pc.printRequestRSpec(request)
