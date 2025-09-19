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
@@ -182,6 +182,10 @@ class Qt < Formula
     # because on macOS `/tmp` -> `/private/tmp`
     inreplace "qtwebengine/src/3rdparty/gn/src/base/files/file_util_posix.cc",
               "FilePath(full_path)", "FilePath(input)"
+    inreplace "qtbase/src/corelib/kernel/qcore_mac.mm",
+              "(current.majorVersion() == 10 && current.minorVersion() >= 16)", 
+              "((current.majorVersion() == 10 && current.minorVersion() >= 16) || 
+              (current.majorVersion() == 11) || (current.majorVersion() == 12))"
 
     # Modify Assistant path as we manually move `*.app` bundles from `bin` to `libexec`.
     # This fixes invocation of Assistant via the Help menu of apps like Designer and
@@ -251,7 +255,10 @@ class Qt < Formula
       end
 
       %W[
-        -DCMAKE_OSX_DEPLOYMENT_TARGET=#{deploy}
+        -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0
+        -DQT_BUILD_TESTS=OFF -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TOOLS=OFF
+        -DFEATURE_dbus=OFF -DFEATURE_vulkan=OFF -DFEATURE_opengl=OFF
+        -DBUILD_qtgraphs=OFF -DBUILD_qtmultimedia=OFF -DBUILD_qtspeech=OFF -DBUILD_qtwebview=OFF -DBUILD_qtquick3d=OFF -DBUILD_qtquick3dphysics=OFF -DBUILD_qt3d=OFF -DBUILD_qtcharts=OFF -DBUILD_qtvirtualkeyboard=OFF -DBUILD_qt5compat=OFF -DBUILD_qtactiveqt=OFF -DBUILD_qtcoap=OFF -DBUILD_qtconnectivity=OFF -DBUILD_qtdatavis3d=OFF -DBUILD_qtgrpc=OFF -DBUILD_qthttpserver=OFF -DBUILD_qtlanguageserver=OFF -DBUILD_qtlocation=OFF -DBUILD_qtpositioning=OFF -DBUILD_qtlottie=OFF -DBUILD_qtmqtt=OFF -DBUILD_qtnetworkauth=OFF -DBUILD_qtopcua=OFF -DBUILD_qtremoteobjects=OFF -DBUILD_qtscxml=OFF -DBUILD_qtsensors=OFF -DBUILD_qtserialbus=OFF -DBUILD_qtserialport=OFF -DBUILD_qtdoc=OFF  -DBUILD_qttranslations=OFF -DBUILD_qtwayland=OFF -DBUILD_qtwebchannel=OFF -DBUILD_qtwebsockets=OFF -DBUILD_qtquickeffectmaker=OFF -DBUILD_qtquicktimeline=OFF
         -DQT_FEATURE_ffmpeg=OFF
       ]
     else
EOF

    HOMEBREW_DEVELOPER=1 brew install --build-from-source --formula ./qt.rb
    # brew uninstall vulkan-headers vulkan-loader molten-vk node
else
    brew install qt@6
fi

brew install --verbose \
    copyq/kde/kf6-knotifications \
    copyq/kde/kf6-kstatusnotifieritem
