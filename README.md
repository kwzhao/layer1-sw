# layer1-sw

CloudLab profile for provisioning the layer-1 switch testbed used by the
CloudLab experiments in
[Prediction-Guided Control in Data Center Networks](https://arxiv.org/html/2601.03593v1).

This repository is the profile/bootstrap layer. It allocates CloudLab hardware,
connects hosts to a physical switch with layer-1 links, and starts the software
components needed by the experiment. The workload generator and controller code
are cloned at boot from external repositories.

## Topology

The profile creates:

- one CloudLab layer-1 switch named `mysw`;
- `nr_nodes` bare-metal hosts named `node0`, `node1`, ...;
- one `L1Link` from each host to the switch;
- static host addresses in `192.168.1.0/24`.

By convention, `node0` is the manager and all other nodes are workers. The
paper's CloudLab experiments used five `xl170` machines connected by 10G links
to a Dell S4048-ON switch: one manager and four traffic endpoints.

## Repository Contents

- `profile.py`: CloudLab geni-lib profile.
- `setup-node.sh`: common per-host setup, including packages, Rust, shell
  configuration, DCTCP, and TCP sysctls.
- `setup-manager.sh`: manager setup. It clones `netiken/emu`, starts the
  manager process, installs Docker, starts Prometheus, builds Workfeed's
  sampler, and starts the sampler.
- `setup-worker.sh`: worker setup. It clones `netiken/emu`, starts an emu
  worker, builds Workfeed's eBPF TCP monitor, and starts the monitor.

CloudLab checks out this repository on every experiment node at
`/local/repository`. The profile's startup services execute the setup scripts
from that path.

## CloudLab Profile Setup

Create a CloudLab profile backed by this Git repository.

Suggested profile source settings:

- Repository URL: `https://github.com/kwzhao/layer1-sw.git`
- Branch: the branch containing the desired `profile.py`
- Profile script: `profile.py`

If using a private fork or SSH URL, make sure CloudLab has access to the
repository. Push changes before instantiating a new experiment; CloudLab reads
from the configured Git branch, not from a local checkout.

## Profile Parameters

`profile.py` exposes the following CloudLab parameters:

| Parameter | Default | Meaning |
| --- | --- | --- |
| `nr_nodes` | `5` | Number of bare-metal nodes to allocate. |
| `phystype` | `dell-s4048` | Switch hardware type. Supported options are `dell-s4048` and `mlnx-sn2410`. |
| `user` | `kwzhao` | Unix user used to run startup scripts. This must match the account created on the CloudLab nodes. |
| `branch` | `main` | Branch of `https://github.com/netiken/emu.git` to clone on each node. This is not the branch of this profile repository. |

The profile currently requests `xl170` hosts and the Ubuntu 22.04 standard
CloudLab image:

```python
node.hardware_type = "xl170"
node.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU22-64-STD"
```

## Boot Sequence

When the experiment starts:

1. CloudLab provisions the requested bare-metal nodes and switch.
2. CloudLab checks out this repository under `/local/repository` on each node.
3. `node0` runs:

   ```sh
   /local/repository/setup-manager.sh <emu-branch> <worker-ip>...
   ```

4. Each worker runs:

   ```sh
   /local/repository/setup-worker.sh <emu-branch> <worker-id> <worker-ip> <manager-ip>
   ```

5. All nodes run `setup-node.sh` before starting their role-specific services.
6. The manager and workers sleep for 10 minutes before starting emu, giving the
   CloudLab switch fabric time to finish coming up.

Logs are written in the CloudLab user's home directory:

- `~/emu.log` on manager and workers
- `~/sampler.log` on the manager
- `~/tcp_monitor.log` on workers

Prometheus is started on the manager and listens on port `9090`. Worker metrics
are scraped from port `9000`.

## External Repositories

The startup scripts clone:

- `https://github.com/netiken/emu.git`
- `https://github.com/kwzhao/workfeed.git`

The `branch` profile parameter applies only to `netiken/emu`. `workfeed` is
cloned from its default branch.

## Operational Notes

- Startup is intentionally heavy: nodes install packages, Rust tooling, Docker,
  eBPF dependencies, and build Rust/C components at boot.
- The scripts assume outbound Internet access from the CloudLab nodes.
- The scripts are run through `sudo -u <user> -H ...`; if the `user` parameter
  does not match the CloudLab account on the node, startup will fail.
- The profile assigns `node0` the address `192.168.1.0`. That is unusual for a
  `/24`; preserve it only if the existing experiment code expects this address.
- The switch is allocated through CloudLab's layer-1 support. Any experiment
  logic that changes switch scheduling, ECN/DCTCP thresholds, or queue weights
  lives outside this profile.

## Quick Checks After Instantiation

From `node0`:

```sh
tail -f ~/emu.log
tail -f ~/sampler.log
curl http://localhost:9090/-/ready
```

From a worker:

```sh
tail -f ~/emu.log
tail -f ~/tcp_monitor.log
ip addr
sysctl net.ipv4.tcp_congestion_control
```

To verify connectivity, ping between the manager and workers using the
`192.168.1.x` addresses assigned by the profile.
