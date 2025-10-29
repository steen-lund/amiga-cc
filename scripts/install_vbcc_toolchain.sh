#!/bin/sh

# Script to install the core VBCC toolchain (vbcc compiler, vasm assemblers, vlink linker)
# This script is called from install_amiga_toolchain.sh
# Expects TEMP_BUILD_DIR, PROJECT_PATH, and SCRIPT_DIR environment variables to be set

if [ -z "$TEMP_BUILD_DIR" ] || [ -z "$PROJECT_PATH" ] || [ -z "$SCRIPT_DIR" ]; then
  echo "Error: TEMP_BUILD_DIR, PROJECT_PATH, and SCRIPT_DIR must be set"
  exit 1
fi

# Download packages to temp dir
if ! wget -c http://sun.hasenbraten.de/vasm/release/vasm.tar.gz; then
  echo "Failed to download vasm.tar.gz"
  exit 1
fi

if ! wget -c http://sun.hasenbraten.de/vlink/release/vlink.tar.gz; then
  echo "Failed to download vlink.tar.gz"
  exit 1
fi

if ! git clone https://github.com/steen-lund/vbcc.git; then
  echo "Failed to clone vbcc repository"
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

if ! wget -c https://aminet.net/dev/c/vbcc_PosixLib.lha; then
  echo "Failed to download vbcc_PosixLib.lha"
  exit 1
fi

# Enter vbcc clone
cd vbcc

if [ ! -d bin ]; then
  mkdir bin
fi

# Build vbcc compiler(s) for m68k
make TARGET=m68k

# Build vbcc compiler(s) for PPC
make TARGET=ppc

# Copy compiled binaries to PROJECT PATH
cp -r bin "$PROJECT_PATH/"

# Exit vbcc clone, we are now back in TEMP_BUILD_DIR
cd ..

# Extract and build vasm
tar zxvf vasm.tar.gz
cd vasm

# Build vasm for m68k
make CPU=m68k SYNTAX=mot
cp vasmm68k_mot vobjdump "$VBCC/bin"

# Build vasm for ppc as well
make CPU=ppc SYNTAX=std
cp vasmppc_std "$VBCC/bin"

# Exit vasm folder, we are now back in the TEMP_BUILD_DIR
cd ..

# Extract and build vlink
tar zxvf vlink.tar.gz
cd vlink
make
cp vlink "$VBCC/bin"
# Exit vlink folder, we are now back in the TEMP_BUILD_DIR
cd ..

# Install the target configs, includes and libs for m68k Amiga OS
lha xq vbcc_target_m68k-amigaos.lha
cp -r vbcc_target_m68k-amigaos/* "$PROJECT_PATH/"

# Install the target configs, includes and libs for PPC WarpOS
lha xq vbcc_target_ppc-warpos.lha
cp -r vbcc_target_ppc-warpos/* "$PROJECT_PATH/"

# This actually overwrites all configs with config files adapter for a "unix" environment
# i.e no Amiga path name conventions and relies on VBCC env var
cd "$PROJECT_PATH"
tar zxvf "$TEMP_BUILD_DIR/vbcc_unix_config.tar.gz"
cd "$TEMP_BUILD_DIR"

# Install the posix support for vbcc
if ! lha xq vbcc_PosixLib.lha; then
  echo "Failed to extract vbcc_PosixLib.lha"
  exit 1
fi

mkdir -p "$PROJECT_PATH/targets/posix"
cd PosixLib

if [ -d include ]; then
  cp -r include "$PROJECT_PATH/targets/posix"
else
  echo "WARNING: vbcc_PosixLib include directory not found"
fi

if [ -f AmigaOS3/posix.lib ]; then
  cp AmigaOS3/posix.lib "$PROJECT_PATH/targets/m68k-amigaos/lib/posix.lib"
else
  echo "WARNING: AmigaOS3/posix.lib not found"
fi

if [ -f WarpOS/posix.lib ]; then
  cp WarpOS/posix.lib "$PROJECT_PATH/targets/ppc-warpos/lib/posix.lib"
else
  echo "WARNING: WarpOS/posix.lib not found"
fi

# Copy posix configs if they exist
if [ -d "$SCRIPT_DIR/posix_configs" ]; then
  cp "$SCRIPT_DIR/posix_configs"/* "$PROJECT_PATH/config/"
else
  echo "WARNING: posix_configs directory not found at $SCRIPT_DIR/posix_configs"
fi

cd ..

echo "VBCC toolchain installation completed successfully"
