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

if [[ $BUILDNAME == 'macOS old' ]]; then
    # libpng version mismatch issue https://stackoverflow.com/questions/36523911#answer-68936263
    curl -kOs https://gist.githubusercontent.com/nicerobot/1515915/raw/uninstall-mono.sh
    chmod +x ./uninstall-mono.sh
    ./uninstall-mono.sh

    # patch then build qt6 locally
    curl -O https://raw.githubusercontent.com/Homebrew/homebrew-core/refs/heads/master/Formula/q/qt.rb

    patch qt.rb <<'EOF'
--- qt.rb
+++ qt.rb
@@ -161,6 +161,11 @@
     inreplace "qtwebengine/src/3rdparty/gn/src/base/files/file_util_posix.cc",
               "FilePath(full_path)", "FilePath(input)"
 
+    inreplace "qtbase/src/corelib/kernel/qcore_mac.mm",
+              "(current.majorVersion() == 10 && current.minorVersion() >= 16)", 
+              "((current.majorVersion() == 10 && current.minorVersion() >= 16) || 
+              (current.majorVersion() == 11) || (current.majorVersion() == 12))"
+
     # Modify Assistant path as we manually move `*.app` bundles from `bin` to `libexec`.
     # This fixes invocation of Assistant via the Help menu of apps like Designer and
     # Linguist as they originally relied on Assistant.app being in `bin`.
@@ -219,7 +224,22 @@
       cmake_args << "-DBUILD_qtwebengine=OFF" if MacOS::Xcode.version < "15.3"
 
       %W[
-        -DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}.0
+        -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0
+        -DQT_BUILD_TESTS=OFF
+        -DQT_BUILD_EXAMPLES=OFF
+        -DQT_BUILD_TOOLS=OFF
+        -DQT_BUILD_DOCS=OFF
+        -DFEATURE_widgets=OFF
+        -DFEATURE_dbus=OFF
+        -DFEATURE_vulkan=OFF
+        -DFEATURE_opengl=OFF
+        -DFEATURE_network=OFF
+        -DBUILD_qtgraphs=OFF
+        -DBUILD_qtmultimedia=OFF
+        -DBUILD_qtwebview=OFF
+        -DBUILD_qtquick3d=OFF
+        -DBUILD_qt3d=OFF
+        -DBUILD_qtchart=OFF
         -DQT_FEATURE_ffmpeg=OFF
       ]
     else
EOF

    brew install --build-from-source --formula ./qt.rb
    # brew uninstall vulkan-headers vulkan-loader molten-vk node
else
    brew install qt@6
fi

brew install --verbose \
    copyq/kde/kf6-knotifications \
    copyq/kde/kf6-kstatusnotifieritem
