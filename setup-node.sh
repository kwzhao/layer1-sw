#!/bin/bash

set -euo pipefail

sudo apt-get -qq update
sudo apt-get -q install -y iperf3 protobuf-compiler sshpass
git clone https://github.com/netiken/emu.git ~/emu
curl https://sh.rustup.rs -sSf | sh -s -- -y
exit 0
