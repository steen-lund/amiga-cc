#!/bin/sh

# Script to install the Amiga NDK (Native Development Kit)
# This script is called from install_amiga_toolchain.sh
# Expects PROJECT_PATH and SCRIPT_DIR environment variables to be set

if [ -z "$TEMP_BUILD_DIR" ] || [ -z "$PROJECT_PATH" ] || [ -z "$SCRIPT_DIR" ]; then
  echo "Error: PROJECT_PATH and SCRIPT_DIR must be set"
  exit 1
fi

# BEGIN NDK SECTION
cd "$TEMP_BUILD_DIR"

# Download NDK to temp folder
if ! wget -c http://aminet.net/dev/misc/NDK3.2.lha; then
  echo "Failed to download NDK3.2.lha"
  exit 1
fi

# Create a subfolder in temp for NDK extraction
NDK_TEMP_DIR="$TEMP_BUILD_DIR/ndk_extract"
mkdir -p "$NDK_TEMP_DIR"

# Extract NDK to the temp subfolder
echo "Extracting NDK to temporary directory..."
cd "$NDK_TEMP_DIR"
if ! lha xq "$TEMP_BUILD_DIR/NDK3.2.lha"; then
  echo "Failed to extract NDK3.2.lha"
  exit 1
fi

# Already in the extracted NDK directory

# Apply WarpOS/PPC patch to compiler-specific.h
echo "Applying WarpOS/PPC patch to NDK compiler-specific.h..."
PATCH_FILE="$SCRIPT_DIR/patches/compiler-specific.h.patch"
if [ -f "$PATCH_FILE" ]; then
  echo "Found patch file: $PATCH_FILE"
  if [ -f Include_H/clib/compiler-specific.h ]; then
    cd Include_H/clib
    echo "Applying patch to $(pwd)/compiler-specific.h"
    if patch -p0 < "$PATCH_FILE" 2>&1; then
      echo "Patch applied successfully"
    else
      echo "WARNING: Failed to apply compiler-specific.h patch"
    fi
    cd "$TEMP_BUILD_DIR"
  else
    echo "WARNING: Include_H/clib/compiler-specific.h not found"
  fi
else
  echo "WARNING: compiler-specific.h.patch not found at $PATCH_FILE"
fi

# Create destination NDK directory if it doesn't exist
if [ ! -d "$VBCC/NDK" ]; then
  mkdir -p "$VBCC/NDK"
fi

# Copy the patched NDK files to the final location
echo "Copying NDK files to $VBCC/NDK..."
if ! cp -r "$NDK_TEMP_DIR"/* "$VBCC/NDK/"; then
  echo "Failed to copy NDK files to $VBCC/NDK/"
  exit 1
fi

# END NDK SECTION

echo "NDK installation completed successfully"
