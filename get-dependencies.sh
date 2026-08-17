#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake             \
    clang             \
    erofs-utils       \
    erofsfuse         \
    fmt               \
    kvantum           \
    libdecor          \
    lld               \
    lxqt-qtplugin     \
    ninja             \
    pipewire-audio    \
    pipewire-jack     \
    python            \
    python-setuptools \
    qqc2-breeze-style \
    qt6-declarative   \
    qt6ct             \
    sdl3              \
    squashfs-tools    \
    squashfuse        \
    vulkan-headers
# Bloating the container so fex maybe work :).
pacman -Syu --needed --noconfirm xorg tk tcl xclip xfce4 xfce4-goodies pavucontrol qt5ct

pacman -Rdd --noconfirm xfce4-screensaver xfce4-power-manager 2>/dev/null || true

pacman -Syu --noconfirm \
    base-devel                 \
    gdb                        \
    git                        \
    ccache                     \
    llvm                       \
    source-highlight           \
    nasm                       \
    \
    cpio                       \
    diffutils                  \
    xxhash                     \
    zlib-ng                    \
    \
    vulkan-broadcom            \
    vulkan-mesa-implicit-layers\
    mesa-utils                 \
    \
    qt6-5compat                \
    qt6-translations           \
    \
    python-pip                 \
    python-cryptography        \
    python-attrs               \
    python-autocommand         \
    python-jaraco.collections  \
    python-jaraco.context      \
    \
    wget                       \
    hiredis                    \
    hidapi                     \
    xcb-util-cursor            \
    bind-tools                 \
    iputils                    \
    \
    nano                       \
    onetbb                     \
    perl-error                 \
    perl-mailtools             \
    perl-timedate
mv /usr/bin/curl /usr/bin/real_curl
#echo "Installing debloated packages..."
#echo "---------------------------------------------------------------"
#get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package

# If the application needs to be manually built that has to be done down here

# if you also have to make nightly releases check for DEVEL_RELEASE = 1
#
# if [ "${DEVEL_RELEASE-}" = 1 ]; then
# 	nightly build steps
# else
# 	regular build steps
# fi
echo "Making nightly build of FEX-Emu..."
echo "---------------------------------------------------------------"
REPO="https://github.com/FEX-Emu/FEX"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone --recursive --depth 1 "$REPO" ./FEX
echo "$VERSION" > ~/version

# Target ARMv8 baseline extensions to support older ARMv8 cpus
# found in the Raspberry Pi 5 as GitHub actions seems to target modern cpus
cd FEX
mkdir build && cd build
CC=clang CXX=clang++ cmake .. \
    -DTUNE_CPU=generic \
	-DTUNE_ARCH=generic \
    -DENABLE_BINFMT=OFF \
    -DCMAKE_AR=/usr/bin/ar \
    -DCMAKE_RANLIB=/usr/bin/ranlib \
    -DCMAKE_C_COMPILER_AR=/usr/bin/ar \
    -DCMAKE_CXX_COMPILER_AR=/usr/bin/ar \
    -DCMAKE_C_COMPILER_RANLIB=/usr/bin/ranlib \
    -DCMAKE_CXX_COMPILER_RANLIB=/usr/bin/ranlib \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_LINKER=lld \
    -DENABLE_LTO=True \
    -DBUILD_TESTING=False \
    -DENABLE_ASSERTIONS=False \
    -G Ninja
ninja
ninja install
#ninja binfmt_misc
