#!/bin/bash

# Configure zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo -k chsh -s $(which zsh) ${USER}

# Install Rust
curl https://sh.rustup.rs -sSf | sh -s -- -y

# Install zsh plugins
curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to ~/.cargo/bin
mkdir -p ~/.config/sheldon
cat << EOF > ~/.config/sheldon/plugins.toml
shell = "zsh"

[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"

[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"

[plugins.zsh-vi-mode]
github = "jeffreytse/zsh-vi-mode"
EOF

echo 'eval "$(~/.cargo/bin/sheldon source)"' >> ~/.zshrc
echo 'ZVM_VI_INSERT_ESCAPE_BINDKEY=jk' >> ~/.zshrc
