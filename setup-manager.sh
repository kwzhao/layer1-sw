#!/bin/bash

set -euo pipefail

/local/repository/setup-node.sh

git clone https://github.com/netiken/emu.git ~/emu
cd ~/emu || exit

cargo run --release manager --port 50000
