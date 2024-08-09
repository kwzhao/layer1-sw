#!/bin/bash

set -euo pipefail

sudo apt-get -qq update
sudo apt-get -q install -y iperf3 protobuf-compiler
git clone https://github.com/netiken/emu.git ~/emu
/local/repository/configure-shell.sh || exit 1
exit 0
