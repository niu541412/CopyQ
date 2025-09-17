#!/usr/bin/env bash
# Installs build dependencies.
set -xeuo pipefail

# Create repository for Homebrew.
(
    cd utils/github/homebrew/
    git config --global user.email "noreply@github.com"
    git config --global user.name "GitHub Actions"
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
    /usr/local/bin/pip3* \
    /usr/local/bin/python3-config*

brew uninstall cmake

# Install Homebrew: https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew tap copyq/kde utils/github/homebrew/

if [[ $BUILDNAME == 'macOS old' ]]; then
    # libpng version mismatch issue, https://stackoverflow.com/questions/36523911#answer-68936263
    curl -kOs https://gist.githubusercontent.com/nicerobot/1515915/raw/uninstall-mono.sh
    chmod +x ./uninstall-mono.sh
    ./uninstall-mono.sh

    # patch then build qt@6 locally，besides exclude some modules and features to reduce build time.
    curl -O https://raw.githubusercontent.com/Homebrew/homebrew-core/refs/heads/master/Formula/q/qt.rb

    patch qt.rb <<'EOF'
--- qt.rb
+++ qt.rb
@@ -177,6 +177,11 @@ class Qt < Formula
     # because on macOS `/tmp` -> `/private/tmp`
     inreplace "qtwebengine/src/3rdparty/gn/src/base/files/file_util_posix.cc",
               "FilePath(full_path)", "FilePath(input)"
+    
+    inreplace "qtbase/src/corelib/kernel/qcore_mac.mm",
+              "(current.majorVersion() == 10 && current.minorVersion() >= 16)", 
+              "((current.majorVersion() == 10 && current.minorVersion() >= 16) || 
+              (current.majorVersion() == 11) || (current.majorVersion() == 12))"
 
     # Modify Assistant path as we manually move `*.app` bundles from `bin` to `libexec`.
     # This fixes invocation of Assistant via the Help menu of apps like Designer and
@@ -238,7 +243,10 @@ class Qt < Formula
       cmake_args << "-DQT_FORCE_WARN_APPLE_SDK_AND_XCODE_CHECK=ON" if MacOS.version <= :monterey
 
       %W[
-        -DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}.0
+        -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0
+        -DQT_BUILD_TESTS=OFF -DQT_BUILD_EXAMPLES=OFF
+        -DQT_BUILD_TOOLS=OFF
+        -DQT_BUILD_DOCS=OFF
         -DQT_FEATURE_ffmpeg=OFF
       ]
     else
EOF

    HOMEBREW_DEVELOPER=1 brew install --build-from-source --formula ./qt.rb --verbose
    # brew uninstall vulkan-headers vulkan-loader molten-vk node
else
    brew install qt@6
fi

brew install --verbose \
    copyq/kde/kf6-knotifications \
    copyq/kde/kf6-kstatusnotifieritem
