# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository provides a complete Amiga cross-compilation toolchain setup for Linux/macOS systems using the vbcc compiler. It supports building applications for both classic Amiga (m68k-amigaos) and PowerPC WarpOS (ppc-warpos) platforms from a modern development environment.

## Build Commands

```bash
# Build all example programs (window, primes_m68k, primes_warpos)
make

# Build individual targets
make window          # m68k GUI example using Intuition
make primes_m68k     # m68k console example
make primes_warpos   # PowerPC WarpOS console example

# Clean build artifacts
make clean
```

## Toolchain Installation

The toolchain must be installed before building any programs:

```bash
# Install toolchain (requires sudo)
sudo ./install_amiga_toolchain.sh

# Configure environment variables
./env.sh

# Reload shell configuration
source ~/.zshrc  # for zsh
source ~/.bashrc # for bash
```

Prerequisites (must be installed first):
- `wget` utility
- `lha` decompressor (lha/lhasa depending on platform)
- `git`

## Architecture

### Dual-Target Compilation System

This repository demonstrates cross-platform Amiga development:

1. **m68k-amigaos target**: Classic Amiga systems (68000-68060 CPUs)
   - Compiler flags: `-c99 +aos68k -I$(NDK_INCLUDES)`
   - Link flags: `-lmieee -lamiga -lauto`
   - Uses NDK 3.2 headers and system libraries

2. **ppc-warpos target**: PowerPC WarpOS systems
   - Compiler flags: `-c99 +warpos -I$(NDK_INCLUDES) -O3`
   - Link flags: `-lm`
   - Requires patched NDK headers (compiler-specific.h) for PPC compatibility

### Toolchain Structure

The toolchain is installed to `/opt/vbcc/` with the following components:

- **vbcc compiler**: Built for both m68k and ppc targets
- **vasm assemblers**: `vasmm68k_mot` (Motorola syntax) and `vasmppc_std`
- **vlink linker**: Universal linker for both architectures
- **NDK 3.2**: Amiga Native Development Kit headers and libraries at `/opt/vbcc/NDK_3.2/`
- **Additional libraries**: Installed to `/opt/vbcc/local/`
  - libpng (PNG image format support)
  - SDI headers (System Development Interface)
  - Warp3D (3D graphics API)
  - Picasso96 (RTG graphics system)
  - WarpUP V51 (PowerPC support libraries and LVO files)

### Key Environment Variables

- `VBCC`: Path to vbcc installation (`/opt/vbcc`)
- `PATH`: Must include `$VBCC/bin`
- `NDK_INCLUDES`: Path to NDK headers (`$VBCC/NDK_3.2/Include_H`)

### Cross-Platform Code Patterns

The `primes.c` example demonstrates writing code that compiles for both targets:
- Use standard C library functions (stdio, stdlib, string)
- Avoid architecture-specific features unless conditionally compiled
- Memory-efficient algorithms work well on both m68k and PowerPC

The `window.c` example shows m68k-specific GUI programming:
- Uses Intuition library for window management
- Requires AmigaOS system libraries (`proto/intuition.h`, `proto/dos.h`)
- Uses register-based calling conventions (handled by compiler-specific.h)

### NDK Header Patching

The installation applies a critical patch to `NDK_3.2/Include_H/clib/compiler-specific.h`:
- Disables register-based parameter passing (`__REG__` macro) for PowerPC
- PowerPC uses stack-based calling conventions instead
- Without this patch, PPC builds will fail with incompatible calling convention errors

## File Structure

- `install_amiga_toolchain.sh`: Main installation script (requires sudo)
- `env.sh`: Environment configuration script
- `Makefile`: Build system for example programs
- `window.c`: m68k GUI example using Intuition
- `primes.c`: Cross-platform console example (works on both m68k and PPC)
- `compiler-specific.h.patch`: NDK header patch for PPC compatibility

## Development Notes

- The compiler binary is `vc` (vbcc compiler)
- All binaries are built as native Amiga executables (not host-platform executables)
- Executables must be tested on UAE (Unix Amiga Emulator) or real Amiga hardware
- The toolchain downloads from official sources: vbcc repository, aminet.net, sun.hasenbraten.de
- Additional developer files (libpng, SDI headers, Warp3D, Picasso96, WarpUP) are automatically installed for convenience
