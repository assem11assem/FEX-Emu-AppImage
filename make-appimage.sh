#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/FEX-Emu/FEX/refs/heads/main/Source/Tools/FEXConfig/icon.png
export DESKTOP=DUMMY
export MAIN_BIN=FEX
export DEPLOY_QT=1
export DEPLOY_VULKAN=1
export DEPLOY_PIPEWIRE=1
export DEPLOY_PYTHON=1 #Because Why not.

# Deploy dependencies
quick-sharun /bin/FEX* /usr/bin/FEX* /bin/bash /usr/bin/curl /usr/bin/ping /usr/bin/dig /usr/bin/unsquashfs /usr/bin/squashfuse /usr/bin/*erofs* /bin/*erofs* /usr/lib/libFEXCore.so /usr/share/fex-emu/* /usr/lib/*FEX* #/usr/share/binfmts/FEX* /var/lib/binfmts/FEX*
mv ./AppDir/bin/curl ./AppDir/bin/real_curl
chmod +x ./curl
mv ./curl ./AppDir/bin/curl

#echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}/bin' >> ./AppDir/.env

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
