#!/bin/sh

# Script to install libpng for Amiga (both m68k and PowerPC WarpOS)
# This script is called from install_amiga_toolchain.sh
# Expects TEMP_BUILD_DIR, PROJECT_PATH, SCRIPT_DIR, and VBCC environment variables to be set

if [ -z "$TEMP_BUILD_DIR" ] || [ -z "$PROJECT_PATH" ] || [ -z "$SCRIPT_DIR" ] || [ -z "$VBCC" ]; then
  echo "Error: TEMP_BUILD_DIR, PROJECT_PATH, SCRIPT_DIR, and VBCC must be set"
  exit 1
fi

cd "$TEMP_BUILD_DIR"

# Clone the libpng repository
if ! git clone https://github.com/steen-lund/libpng_aos.git; then
  echo "Failed to clone libong_aos repository"
  exit 1
fi

cd libpng_aos/

# Build the WarpOS library
echo "Building pnglib for PowerPC WarpOS..."
cp scripts/makefile.vbcc.amigaWOS makefile
if ! make ; then
  echo "Failed to build libpng for WarpOS"
  exit 1
fi

# Copy WarpOS library
if [ -f png.lib ]; then
  echo "Installing WarpOS pnglib library..."
  cp png.lib "$VBCC/targets/ppc-warpos/lib/png.lib"
else
  echo "ERROR: WarpOS png.lib not found after build"
  exit 1
fi

# Clean WarpOS build
make clean

# Build the m68k library
echo "Building libpng for m68k AmigaOS..."
cp scripts/makefile.vbcc.amiga68K makefile
if ! make; then
  echo "Failed to build libpng for m68k"
  exit 1
fi

# Copy m68k library
if [ -f png.lib ]; then
  echo "Installing m68k libpng library..."
  cp png.lib "$VBCC/targets/m68k-amigaos/lib/png.lib"
else
  echo "ERROR: m68k png.lib not found after build"
  exit 1
fi

# Copy header files
echo "Installing libpng header files..."
if [ -f png.h ]; then
  cp png.h "$PROJECT_PATH/local/Include_H/png.h"
else
  echo "WARNING: png.h not found"
fi

if [ -f pnglibconf.h ]; then
  cp pnglibconf.h "$PROJECT_PATH/local/Include_H/pnglibconf.h"
else
  echo "WARNING: pnglibconf.h not found"
fi

if [ -f pngconf.h ]; then
  cp pngconf.h "$PROJECT_PATH/local/Include_H/pngconf.h"
else
  echo "WARNING: pngconf.h not found"
fi

# Clean m68k build
make clean

echo "libpng installation completed successfully"

