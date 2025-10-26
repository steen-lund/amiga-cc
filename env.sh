#!/bin/sh

# Set path to the vbcc installation
VBCC_PATH="/opt/vbcc"

# Check if the shell is bash or zsh
if [ $SHELL = "/bin/bash" ] || [ $SHELL = "/usr/bin/bash" ]; then
  SHELL_RC="$HOME/.bashrc"
elif [ $SHELL = "/bin/zsh" ]; then
  SHELL_RC="$HOME/.zshrc"
else
  echo "Unsupported shell. Please use bash or zsh."
  exit 1
fi

# Check if entry exist and add it
if ! grep -q "export VBCC=\"$VBCC_PATH\"" "$SHELL_RC"; then
  echo "export VBCC=\"$VBCC_PATH\"" >> "$SHELL_RC"
  echo "Added VBCC environment variable to $SHELL_RC"
fi

if ! grep -q "export PATH=\"\$VBCC/bin:\$PATH\"" "$SHELL_RC"; then
  echo "export PATH=\"\$VBCC/bin:\$PATH\"" >> "$SHELL_RC"
  echo "Added VBCC/bin to PATH in $SHELL_RC"
fi

if ! grep -q "export NDK_INCLUDES=\"\$VBCC/NDK/Include_H\"" "$SHELL_RC"; then
  echo "export NDK_INCLUDES=\"\$VBCC/NDK/Include_H\"" >> "$SHELL_RC"
  echo "Added NDK/Include_H to NDK_INCLUDES in $SHELL_RC"
  echo "Use -I\$(NDK_INCLUDES) to include the NDK headers in your compiler flags"
fi

echo "Environment configuration completed."