#!/bin/bash

set -euo pipefail

sudo apt-get -qq update
sudo apt-get -q install -y iperf3 protobuf-compiler sshpass
nohup curl https://sh.rustup.rs -sSf | sh -s -- -y
git clone https://github.com/netiken/emu.git ~/emu
exit 0
