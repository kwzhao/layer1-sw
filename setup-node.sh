#!/bin/bash

set -euo pipefail

sudo apt-get -qq update
sudo apt-get -q install -y iperf3 protobuf-compiler sshpass
sudo -u kwzhao curl https://sh.rustup.rs -sSf | sh -s -- -y
sudo -u kwzhao git clone https://github.com/netiken/emu.git ~/emu
exit 0
