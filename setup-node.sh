#!/bin/bash

sudo apt-get -qq update
sudo apt-get -q install -y iperf3
/local/repository/configure-shell.sh || exit 1
git clone https://github.com/netiken/emu.git ~/emu
exit 0
