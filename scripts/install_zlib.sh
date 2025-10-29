#!/bin/sh

# Script to install zlib for Amiga (both m68k and PowerPC WarpOS)
# This script is called from install_amiga_toolchain.sh
# Expects TEMP_BUILD_DIR, PROJECT_PATH, SCRIPT_DIR, and VBCC environment variables to be set

if [ -z "$TEMP_BUILD_DIR" ] || [ -z "$PROJECT_PATH" ] || [ -z "$SCRIPT_DIR" ] || [ -z "$VBCC" ]; then
  echo "Error: TEMP_BUILD_DIR, PROJECT_PATH, SCRIPT_DIR, and VBCC must be set"
  exit 1
fi

cd "$TEMP_BUILD_DIR"

# Clone the zlib repository
if ! git clone https://github.com/steen-lund/zlib_aos.git; then
  echo "Failed to clone zlib_aos repository"
  exit 1
fi

cd zlib_aos/amiga

# Build the WarpOS library
echo "Building zlib for PowerPC WarpOS..."
if ! make -f Makefile.vbccWOS; then
  echo "Failed to build zlib for WarpOS"
  exit 1
fi

# Copy WarpOS library
if [ -f z.lib ]; then
  echo "Installing WarpOS zlib library..."
  cp z.lib "$VBCC/targets/ppc-warpos/lib/z.lib"
else
  echo "ERROR: WarpOS z.lib not found after build"
  exit 1
fi

# Clean WarpOS build
make -f Makefile.vbccWOS clean

# Build the m68k library
echo "Building zlib for m68k AmigaOS..."
if ! make -f Makefile.vbcc68K; then
  echo "Failed to build zlib for m68k"
  exit 1
fi

# Copy m68k library
if [ -f z.lib ]; then
  echo "Installing m68k zlib library..."
  cp z.lib "$VBCC/targets/m68k-amigaos/lib/z.lib"
else
  echo "ERROR: m68k z.lib not found after build"
  exit 1
fi

# Clean m68k build
make -f Makefile.vbcc68K clean

# Go back to zlib_aos root directory
cd ..

# Copy header files
echo "Installing zlib header files..."
if [ -f zlib.h ]; then
  cp zlib.h "$PROJECT_PATH/local/Include_H/zlib.h"
else
  echo "WARNING: zlib.h not found"
fi

if [ -f zconf.h ]; then
  cp zconf.h "$PROJECT_PATH/local/Include_H/zconf.h"
else
  echo "WARNING: zconf.h not found"
fi

echo "zlib installation completed successfully"

