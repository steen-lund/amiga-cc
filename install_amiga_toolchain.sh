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
# install WarpOS
# install Warp3D
# install MiniGL


rm -rf "$TEMP_BUILD_DIR"


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

# Download and install WarpUP V51 developer files
echo "Downloading WarpUP V51 developer files from aminet..."
cd "$PROJECT_PATH"
if ! wget -c http://aminet.net/misc/os/WarpUP_V51Upd.lha; then
  echo "Failed to download WarpUP_V51Upd.lha"
  exit 1
fi

echo "Extracting WarpUP V51 developer files..."
lha x WarpUP_V51Upd.lha

# Install WarpUP includes
if [ -d WarpUP-WarpOS/include ]; then
  echo "Installing WarpUP includes to $PROJECT_PATH/local/Include_h..."
  cp -r WarpUP-WarpOS/include/* "$PROJECT_PATH/local/Include_h/"
fi

# Install WarpUP LVO files
if [ -d WarpUP-WarpOS/LVO ]; then
  echo "Installing WarpUP LVO files to $PROJECT_PATH/local/Include_h/LVO/..."
  mkdir -p "$PROJECT_PATH/local/Include_h/LVO"
  cp -r WarpUP-WarpOS/LVO/* "$PROJECT_PATH/local/Include_h/LVO/"
fi

# Clean up WarpUP archive and extracted files
rm -f WarpUP_V51Upd.lha
rm -rf WarpUP-WarpOS
rm -rf Install*WarpUP*.info
rm -f "WarpUP Install-Script"

# Set proper permissions for system-wide installation
echo "Setting permissions for system-wide access..."
chmod -R a+rX "$PROJECT_PATH"
chmod -R 755 "$PROJECT_PATH/bin"

echo "VBCC toolchain installed successfully to $PROJECT_PATH"
echo "To use the toolchain, run: export VBCC=$PROJECT_PATH && export PATH=\$VBCC/bin:\$PATH"
echo "To add the environment variables to your shell, run: source env.sh"
