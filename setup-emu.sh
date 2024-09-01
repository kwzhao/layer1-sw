#!/bin/bash

git clone https://github.com/netiken/emu.git ~/emu
cd ~/emu || exit
cargo build --release
