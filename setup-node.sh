#!/bin/bash

set -euo pipefail

sudo apt-get -qq update
sudo apt-get -q install -y iperf3 protobuf-compiler
/local/repository/configure-shell.sh
git clone https://github.com/netiken/emu.git ~/emu
cd ~/emu && cargo build --release
exit 0
