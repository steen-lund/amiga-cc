#!/bin/sh

# Check if running as root/sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run with sudo"
  echo "Usage: sudo ./install_amiga_toolchain.sh"
  exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Set the installation path
PROJECT_PATH="/opt/vbcc"

export VBCC="$PROJECT_PATH"
export PATH="$VBCC/bin:$PATH"

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

# BEGIN TOOLCHAIN SECTION
# Call the separate toolchain installation script
export TEMP_BUILD_DIR
export PROJECT_PATH
export SCRIPT_DIR
"$SCRIPT_DIR/scripts/install_vbcc_toolchain.sh"
if [ $? -ne 0 ]; then
  echo "Toolchain installation failed!"
  exit 1
fi
# END TOOLCHAIN SECTION

# BEGIN NDK SECTION
# Call the separate NDK installation script
export PROJECT_PATH
export SCRIPT_DIR
export VBCC
"$SCRIPT_DIR/scripts/install_ndk.sh"
if [ $? -ne 0 ]; then
  echo "NDK installation failed!"
  exit 1
fi
# END NDK SECTION


# Create local directories for additional Amiga developer files
echo "Creating local directories for additional developer files..."
mkdir -p "$PROJECT_PATH/local/Include_H"

echo "Local directories created:"
echo "  - $PROJECT_PATH/local/Include_H (for additional header files)"

# install zlib
"$SCRIPT_DIR/scripts/install_zlib.sh"
if [ $? -ne 0 ]; then
  echo "zlib installation failed!"
  exit 1
fi

# install libpng
"$SCRIPT_DIR/scripts/install_libpng.sh"
if [ $? -ne 0 ]; then
  echo "libpng installation failed!"
  exit 1
fi

# install WarpOS
# install Warp3D
# install MiniGL

rm -rf "$TEMP_BUILD_DIR"

# Set proper permissions for system-wide installation
echo "Setting permissions for system-wide access..."
chmod -R a+rX "$PROJECT_PATH"
chmod -R 755 "$PROJECT_PATH/bin"

echo "VBCC toolchain installed successfully to $PROJECT_PATH"
echo "To use the toolchain, run: export VBCC=$PROJECT_PATH && export PATH=\$VBCC/bin:\$PATH"
echo "To add the environment variables to your shell, run: source env.sh"
