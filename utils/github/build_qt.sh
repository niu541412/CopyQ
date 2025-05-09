#!/usr/bin/env bash
# Installs build dependencies.
set -xeuo pipefail

# Create repository for Homebrew.
(
    cd utils/github/homebrew/
    git init .
    git add .
    git commit -m "Initial"
)

# workaround for symlink issues
rm -rf \
    /usr/local/bin/2to3* \
    /usr/local/bin/idle3* \
    /usr/local/bin/pydoc3* \
    /usr/local/bin/python3* \
    /usr/local/bin/python3-config*

# Install Homebrew: https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew tap copyq/kde utils/github/homebrew/

# if [[ $(uname -m) == 'x86_64' ]]; then
if [[ $BUILDNAME == 'macOS qt' ]]; then
    curl -O https://raw.githubusercontent.com/Homebrew/homebrew-core/refs/heads/master/Formula/q/qt.rb
    patch qt.rb utils/github/qt.rb.patch
    brew install --build-from-source --formula ./qt.rb
    brew uninstall vulkan-headers vulkan-loader molten-vk node
    tar -czf qt6--bottle.tar.gz -C /usr/local/Cellar qt
else
    brew install qt@6
fi