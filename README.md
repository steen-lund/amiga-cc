# Amiga C cross compiler and assembler setup for Linux / Macos

Installs the [vbcc](http://www.compilers.de/vbcc.html) compiler with support for both **m68k-amigaos** (classic Amiga) and **ppc-warpos** (PowerPC WarpOS) targets, along with the vasm assemblers for both architectures.

Prerequisite:
the wget utility and an LHA decompressor:
```
brew install lha (Macos)
sudo apt install wget lhasa (Debian-based distros)
sudo pacman -S wget lhasa (Arch)
```


The toolchain will be installed to `/opt/vbcc`. Since this requires administrator privileges, you'll need to run the installation script with `sudo`:
```
git clone https://github.com/nicolasbauw/amiga-cc.git
cd amiga-cc/
sudo ./install_amiga_toolchain.sh
```

You will soon be prompted by a set of questions, like:
```
Are you building a cross-compiler?
Type y or n [y]:
```

Just press enter each time, and the installation will go on.

When finished, run the env.sh file to add the VBCC environment variables to your zshrc or bashrc file.
```
./env.sh
```

Then close and reopen your terminal session, or run:
```
source ~/.zshrc  # for zsh
source ~/.bashrc # for bash
```

Let's now have a try:
```
make
```

This will compile all three example programs:
- **window** - An m68k-amigaos GUI example (from `window.c`) that opens a window with gadgets
- **primes_m68k** - An m68k-amigaos console example (from `primes.c`) that calculates prime numbers  using the Sieve of Eratosthenes algorithm
- **primes_warpos** - ppc-warpos console example (from `primes.c`) that calculates prime numbers using the Sieve of Eratosthenes algorithm

You can also build them individually:
```
make window          # Build only the m68k GUI example
make primes_m68k     # Build the prime calculator for m68k
make primes_warpos   # Build the prime calculator for WarpOS
```

You'll be excited to try these executables on UAE or a real Amiga machine!

## Examples

This repository includes example programs demonstrating cross-platform development:

### window.c (m68k-amigaos)
A classic Amiga GUI example that demonstrates:
- Opening an Intuition window with gadgets
- Using AmigaOS system libraries
- Proper window handling and cleanup

### primes.c (multi-platform)
A cross-platform console example that compiles for both **m68k-amigaos** and **ppc-warpos**!

## Targets

The toolchain supports two targets:
- **m68k-amigaos**: For classic Amiga systems (68000/68020/68030/68040/68060 CPUs)
- **ppc-warpos**: For WarpOS PowerPC systems

Both compilers and assemblers are installed in `/opt/vbcc/bin/`.

## Credits

This repo was made thanks to informations from [this blog post](https://blitterstudio.com/setting-up-an-amiga-cross-compiler/) and [this youtube video](https://www.youtube.com/watch?v=vFV0oEyY92I).
