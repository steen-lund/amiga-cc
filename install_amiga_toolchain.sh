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

rm -rf "$TEMP_BUILD_DIR"

# Set proper permissions for system-wide installation
echo "Setting permissions for system-wide access..."
chmod -R a+rX "$PROJECT_PATH"
chmod -R 755 "$PROJECT_PATH/bin"

echo "VBCC toolchain installed successfully to $PROJECT_PATH"
echo "To use the toolchain, run: export VBCC=$PROJECT_PATH && export PATH=\$VBCC/bin:\$PATH"
echo "To add the environment variables to your shell, run: source env.sh"
