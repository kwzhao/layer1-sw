#!/bin/bash

set -euo pipefail

/local/repository/setup-node.sh

git clone https://github.com/netiken/emu.git ~/emu
cd ~/emu || exit

id="$1"
advertise_ip="$2"
manager_ip="$3"

cargo run --release worker \
    --id "$id" \
    --advertise-addr "${advertise_ip}:50000" \
    --manager-addr "${manager_ip}:50000" \
    --metrics-addr 0.0.0.0:9000 &
