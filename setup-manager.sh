#!/bin/bash

set -euo pipefail

/local/repository/setup-node.sh

git clone https://github.com/netiken/emu.git ~/emu
cd ~/emu || exit

nohup ~/.cargo/bin/cargo run --release manager \
    --port 50000 \
    >emu.log 2>&1 &
