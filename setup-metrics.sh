#!/bin/bash

set -euo pipefail

/local/repository/setup-node.sh

# Add Docker's official GPG key.
sudo apt-get -qq update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources.
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get -qq update

# Install the docker packages.
sudo apt-get -q install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Collect IP addresses into an array.
ip_addresses=("$@")

# Build the targets list.
targets=""
port=9001

for ip in "${ip_addresses[@]}"; do
    targets+="\"$ip:$port\", "
    ((port++))
done

# Remove trailing comma and space.
targets="${targets%, }"

# Generate `prometheus.yml` configuration file.
cat <<EOF >~/prometheus.yml
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: emu
    static_configs:
      - targets: [$targets]
EOF

# Wait for the switch to come up.
sleep 2m

# TODO: Start Prometheus.
