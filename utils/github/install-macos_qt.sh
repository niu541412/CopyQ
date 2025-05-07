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

# brew install qt@6 --only-dependencies
brew install qt@6 

# # 从最近一次成功的 run 中下载某个 artifact
# RUN_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
#     "https://api.github.com/repos/$REPO/actions/workflows/build_qt.yml/runs?branch=main&status=success&per_page=1" |
#     jq -r '.workflow_runs[0].id')

# ARTIFACT_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
#     "https://api.github.com/repos/$REPO/actions/runs/$RUN_ID/artifacts" |
#     jq -r ".artifacts[] | select(.name==\"qt-bottle\") | .id")

# curl -L -H "Authorization: token $GITHUB_TOKEN" \
#     -o qt-bottle.zip \
#     https://api.github.com/repos/niu541412/CopyQ/actions/artifacts/$ARTIFACT_ID/zip


ARTIFACT_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$REPO/actions/runs/14840720585/artifacts" |
    jq -r ".artifacts[] | select(.name==\"qt-bottle\") | .id")

curl -L -H "Authorization: token $GITHUB_TOKEN" \
    -o qt-bottle.zip \
    https://api.github.com/repos/niu541412/CopyQ/actions/artifacts/$ARTIFACT_ID/zip

mkdir qt-bak
mv /usr/local/Cellar/qt qt-bak/
unzip qt-bottle.zip
tar xzf qt--*bottle*tar.gz
cp -r qt /usr/local/Cellar/
rm -r /usr/local/Cellar/qt/6.9.0/lib/QtGui.framework/Versions/A
mv  qt-bak/qt/6.9.0/lib/QtGui.framework/Versions/A /usr/local/Cellar/qt/6.9.0/lib/QtGui.framework/Versions/

brew link qt

brew install \
    copyq/kde/kf6-knotifications \
    copyq/kde/kf6-kstatusnotifieritem

brew list --versions
