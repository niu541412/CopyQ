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

brew install qt@6 --only-dependencies
curl -L -H "Authorization: token $GITHUB_TOKEN" \
     -o qt-bottle.zip \
     https://api.github.com/repos/niu541412/CopyQ/actions/artifacts/3064011668/zip

unzip qt-bottle.zip
tar xzf qt--*bottle*tar.gz
mv qt /usr/local/Cellar/
brew link qt

brew install \
    copyq/kde/kf6-knotifications \
    copyq/kde/kf6-kstatusnotifieritem

brew list --versions