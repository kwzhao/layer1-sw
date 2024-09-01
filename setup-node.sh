#!/bin/bash

set -euo pipefail

sudo apt-get -qq update
sudo apt-get -q install -y iperf3 protobuf-compiler sshpass
sudo -u kwzhao -H /local/repository/setup-shell.sh
sudo -u kwzhao -H /local/repository/setup-emu.sh
exit 0
