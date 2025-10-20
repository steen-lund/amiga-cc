#!/bin/sh

# Set the installation path
PROJECT_PATH="/opt/vbcc"

if ! command -v wget &> /dev/null
then
  echo "Please install wget !"
  exit
fi

if ! command -v lha &> /dev/null
then
  echo "Please install an lha decompressor !"
  exit
fi

if ! command -v git &> /dev/null
then
  echo "Please install git !"
  exit
fi

TEMP_BUILD_DIR="/tmp/vbcc_build_$$"
mkdir -p "$TEMP_BUILD_DIR"
mkdir -p "$PROJECT_PATH"

cd "$TEMP_BUILD_DIR"

if ! wget -c http://sun.hasenbraten.de/vasm/release/vasm.tar.gz; then
  echo "Failed to download vasm.tar.gz"
  exit 1
fi

if ! wget -c http://sun.hasenbraten.de/vlink/release/vlink.tar.gz; then
  echo "Failed to download vlink.tar.gz"
  exit 1
fi

if ! wget -c http://www.ibaug.de/vbcc/vbcc.tar.gz; then
  echo "Failed to download vbcc.tar.gz"
  exit 1
fi

if ! wget -c http://phoenix.owl.de/vbcc/current/vbcc_target_m68k-amigaos.lha; then
  echo "Failed to download vbcc_target_m68k-amigaos.lha"
  exit 1
fi

if ! wget -c http://phoenix.owl.de/vbcc/current/vbcc_target_ppc-warpos.lha; then
  echo "Failed to download vbcc_target_ppc-warpos.lha"
  exit 1
fi

if ! wget -c http://phoenix.owl.de/vbcc/current/vbcc_unix_config.tar.gz; then
  echo "Failed to download vbcc_unix_config.tar.gz"
  exit 1
fi

tar zxvf vbcc.tar.gz
cd vbcc

if [ ! -d bin ]; then
  mkdir bin
fi

# Build for m68k
make TARGET=m68k

# Build for PPC
make TARGET=ppc

cp -r bin "$PROJECT_PATH/"

# Copy PPC compiler components
#echo "Installing PPC compiler components..."
#if [ -f bin/vbccppc ]; then
#  cp bin/vbccppc "$PROJECT_PATH/bin/"
#  echo "  - Installed vbccppc (PPC code generator)"
#else
#  echo "  WARNING: vbccppc not found!"
#fi

#if [ -f bin/vscppc ]; then
#  cp bin/vscppc "$PROJECT_PATH/bin/"
#  echo "  - Installed vscppc (PPC scheduler/optimizer)"
#else
#  echo "  WARNING: vscppc not found!"
#fi

cd ..

lha x vbcc_target_m68k-amigaos.lha
cp -r vbcc_target_m68k-amigaos/* "$PROJECT_PATH/"

lha x vbcc_target_ppc-warpos.lha
cp -r vbcc_target_ppc-warpos/* "$PROJECT_PATH/"

cd "$PROJECT_PATH"
tar zxvf "$TEMP_BUILD_DIR/vbcc_unix_config.tar.gz"

export VBCC="$PROJECT_PATH"
export PATH="$VBCC/bin:$PATH"

cd "$TEMP_BUILD_DIR"

tar zxvf vasm.tar.gz
cd vasm
make CPU=m68k SYNTAX=mot
cp vasmm68k_mot vobjdump "$VBCC/bin"

# Build vasm for ppc as well
make CPU=ppc SYNTAX=std
cp vasmppc_std "$VBCC/bin"

cd ..

tar zxvf vlink.tar.gz
cd vlink
make
cp vlink "$VBCC/bin"

cd "$VBCC"

if [ ! -d NDK_3.2 ]; then
  mkdir NDK_3.2
fi

cd NDK_3.2

if ! wget -c http://aminet.net/dev/misc/NDK3.2.lha; then
  echo "Failed to download NDK3.2.lha"
  exit 1
fi

lha x NDK3.2.lha

# Apply WarpOS/PPC patch to compiler-specific.h
echo "Applying WarpOS/PPC patch to NDK compiler-specific.h..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/compiler-specific.h.patch" ]; then
  cd Include_H/clib
  if patch -p0 < "$SCRIPT_DIR/compiler-specific.h.patch"; then
    echo "Patch applied successfully"
  else
    echo "WARNING: Failed to apply compiler-specific.h patch"
  fi
  cd ../..
else
  echo "WARNING: compiler-specific.h.patch not found in $SCRIPT_DIR"
fi

rm -rf "$TEMP_BUILD_DIR"

# Create local directories for additional Amiga developer files
echo "Creating local directories for additional developer files..."
mkdir -p "$PROJECT_PATH/local/Include_h"
mkdir -p "$PROJECT_PATH/local/lib"

echo "Local directories created:"
echo "  - $PROJECT_PATH/local/Include_h (for additional header files)"
echo "  - $PROJECT_PATH/local/lib (for additional libraries)"

# Download and install libpng
echo "Downloading libpng from aminet..."
cd "$PROJECT_PATH"
if ! wget -c http://aminet.net/dev/lib/libpng1640_a68k.lha; then
  echo "Failed to download libpng1640_a68k.lha"
  exit 1
fi

echo "Extracting libpng..."
lha x libpng1640_a68k.lha

# Install libpng includes and libraries
if [ -d libpng1640/include ]; then
  echo "Installing libpng headers to $PROJECT_PATH/local/Include_h..."
  cp -r libpng1640/include/* "$PROJECT_PATH/local/Include_h/"
fi

if [ -d libpng1640/lib ]; then
  echo "Installing libpng libraries to $PROJECT_PATH/local/lib..."
  cp -r libpng1640/lib/* "$PROJECT_PATH/local/lib/"
fi

# Clean up libpng archive and extracted files
rm -f libpng1640_a68k.lha
rm -rf libpng1640

# Download and install SDI headers
echo "Downloading SDI headers from aminet..."
cd "$PROJECT_PATH"
if ! wget -c http://aminet.net/dev/c/SDI_headers.lha; then
  echo "Failed to download SDI_headers.lha"
  exit 1
fi

echo "Extracting SDI headers..."
lha x SDI_headers.lha

# Install SDI headers
if [ -d SDI/includes ]; then
  echo "Installing SDI headers to $PROJECT_PATH/local/Include_h..."
  cp -r SDI/includes/* "$PROJECT_PATH/local/Include_h/"
fi

# Clean up SDI headers archive and extracted files
rm -f SDI_headers.lha
rm -rf SDI

# Download and compile fd2pragma tool from source
echo "Cloning fd2pragma from GitHub..."
cd "$TEMP_BUILD_DIR"
if ! git clone https://github.com/adtools/fd2pragma.git; then
  echo "Failed to clone fd2pragma repository"
  exit 1
fi

echo "Compiling fd2pragma..."
cd fd2pragma
if ! make; then
  echo "Failed to compile fd2pragma"
  exit 1
fi

# Install fd2pragma binary
if [ -f fd2pragma ]; then
  echo "Installing fd2pragma to $PROJECT_PATH/bin..."
  cp fd2pragma "$PROJECT_PATH/bin/"
  chmod 755 "$PROJECT_PATH/bin/fd2pragma"
else
  echo "WARNING: fd2pragma binary not found after compilation"
fi

cd "$TEMP_BUILD_DIR"

# Download and install Warp3D developer files
echo "Downloading Warp3D developer files from aminet..."
cd "$PROJECT_PATH"
if ! wget -c http://aminet.net/dev/misc/Warp3DDev-4.2a.lha; then
  echo "Failed to download Warp3DDev-4.2a.lha"
  exit 1
fi

echo "Extracting Warp3D developer files..."
lha x Warp3DDev-4.2a.lha

# Install Warp3D headers
if [ -d Warp3D_Devel/Include ]; then
  echo "Installing Warp3D headers to $PROJECT_PATH/local/Include_h..."
  cp -r Warp3D_Devel/Include/* "$PROJECT_PATH/local/Include_h/"
fi

# Clean up Warp3D archive and extracted files
rm -f Warp3DDev-4.2a.lha
rm -rf Warp3D_Devel

# Download and install Picasso96 Card Developer files
echo "Downloading Picasso96 Card Developer files from aminet..."
cd "$PROJECT_PATH"
if ! wget -c http://aminet.net/dev/misc/P96CardDevelop.lha; then
  echo "Failed to download P96CardDevelop.lha"
  exit 1
fi

echo "Extracting Picasso96 Card Developer files..."
lha x P96CardDevelop.lha

# Install P96 Card Developer headers
if [ -d Picasso96Develop/PrivateInclude ]; then
  echo "Installing P96 Card Developer headers to $PROJECT_PATH/local/Include_h..."
  cp -r Picasso96Develop/PrivateInclude/* "$PROJECT_PATH/local/Include_h/"
fi

# Clean up P96CardDevelop archive and extracted files
rm -f P96CardDevelop.lha
rm -rf Picasso96Develop

# Download and install Picasso96 Developer files
echo "Downloading Picasso96 Developer files from aminet..."
cd "$PROJECT_PATH"
if ! wget -c http://aminet.net/dev/misc/P96Develop.lha; then
  echo "Failed to download P96Develop.lha"
  exit 1
fi

echo "Extracting Picasso96 Developer files..."
lha x P96Develop.lha

# Install P96 Developer headers and libraries
if [ -d Picasso96Develop/Include ]; then
  echo "Installing P96 Developer headers to $PROJECT_PATH/local/Include_h..."
  cp -r Picasso96Develop/Include/* "$PROJECT_PATH/local/Include_h/"
fi

if [ -d Picasso96Develop/Lib ]; then
  echo "Installing P96 Developer libraries to $PROJECT_PATH/local/lib..."
  cp -r Picasso96Develop/Lib/* "$PROJECT_PATH/local/lib/"
fi

# Clean up P96Develop archive and extracted files
rm -f P96Develop.lha
rm -rf Picasso96Develop

# Set proper permissions for system-wide installation
echo "Setting permissions for system-wide access..."
chmod -R a+rX "$PROJECT_PATH"
chmod -R 755 "$PROJECT_PATH/bin"

echo "VBCC toolchain installed successfully to $PROJECT_PATH"
echo "To use the toolchain, run: export VBCC=$PROJECT_PATH && export PATH=\$VBCC/bin:\$PATH"
echo "To add the environment variables to your shell, run: source env.sh"
