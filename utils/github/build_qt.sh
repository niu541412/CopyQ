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
    qt_minimum_target=12.0
    curl -O https://raw.githubusercontent.com/Homebrew/homebrew-core/refs/heads/master/Formula/q/qt.rb
    sed -i.bak "s|-DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}\.0|-DCMAKE_OSX_DEPLOYMENT_TARGET=${qt_minimum_target}|g" qt.rb
    mv qt.rb.bak qt.rb
    brew install --build-from-source --build-bottle  --formula ./qt.rb
    brew uninstall vulkan-headers vulkan-loader molten-vk node
    brew tap --force homebrew/core
    brew bottle --force-core-tap qt
else
    brew install qt@6
fi

brew install \
    copyq/kde/kf6-knotifications \
    copyq/kde/kf6-kstatusnotifieritem