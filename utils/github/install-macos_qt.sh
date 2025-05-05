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

echo "--------- $(xcrun --show-sdk-path) ---------"

brew install qt@6 --only-dependencies
curl -L -H "Authorization: token $GITHUB_TOKEN" \
     -o qt-bottle.zip \
     https://api.github.com/repos/niu541412/CopyQ/actions/artifacts/3058152208/zip

unzip qt-bottle.zip
mv qt--*bottle*tar.gz $(brew --cache qt)

brew --force install qt@6

echo "+++++++++ $(xcrun --show-sdk-path) +++++++++"

brew install \
    copyq/kde/kf6-knotifications \
    copyq/kde/kf6-kstatusnotifieritem

brew list --versions