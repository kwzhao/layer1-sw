#!/bin/bash

set -euo pipefail

sudo apt-get -qq update
sudo apt-get -q install -y iperf3 protobuf-compiler sshpass
sudo -u kwzhao /local/repository/configure-shell.sh
sudo -u kwzhao git clone https://github.com/netiken/emu.git ~/emu
exit 0
