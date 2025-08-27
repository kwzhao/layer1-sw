#!/bin/bash

set -euo pipefail

/local/repository/setup-node.sh

branch="$1"
id="$2"
advertise_ip="$3"
manager_ip="$4"

git clone --branch "${branch}" https://github.com/netiken/emu.git ~/emu
cd ~/emu || exit

# Wait for the switch to come up.
sleep 6m

# Start emu worker
nohup ~/.cargo/bin/cargo run --release worker \
    --id "$id" \
    --advertise-ip "${advertise_ip}" \
    --control-port 50000 \
    --data-port 50001 \
    --manager-addr "${manager_ip}:50000" \
    --metrics-addr 0.0.0.0:9000 \
    >emu.log 2>&1 &

cd ~ || exit

# Install eBPF development tools
sudo apt-get -q install -y \
    linux-headers-"$(uname -r)" \
    libbpf-dev \
    llvm \
    clang \
    gcc-multilib \
    build-essential \
    linux-tools-"$(uname -r)" \
    linux-tools-common \
    linux-tools-generic
sudo apt-get -q install -y \
    libelf-dev \
    zlib1g-dev \
    libbfd-dev \
    libcap-dev \
    pahole

# Fetch and compile TCP monitor
git clone https://github.com/kwzhao/workfeed.git ~/workfeed
cd workfeed/ebpf || exit
sudo bpftool btf dump file /sys/kernel/btf/vmlinux format c >include/vmlinux.h
make build/tcp_monitor

# Start tcp_monitor in daemon mode, sending to manager's sampler on port 50001
nohup sudo ~/workfeed/ebpf/build/tcp_monitor --daemon \
    --udp-host "${manager_ip}" \
    --udp-port 50001 \
    --batch-size 128 \
    --flush-ms 200 \
    >tcp_monitor.log 2>&1 &
