CC = vc
CFLAGS_M68K = -c99 +aos68k -I$(NDK_INCLUDES)
CFLAGS_WARPOS = -c99 +warpos -I$(NDK_INCLUDES) -O3
LDFLAGS_M68K = -lmieee -lamiga -lauto
LDFLAGS_WARPOS = -lm

all: window primes_m68k primes_warpos

window:
	$(CC) $(CFLAGS_M68K) -o window window.c $(LDFLAGS_M68K)

primes_m68k:
	$(CC) $(CFLAGS_M68K) -o primes_m68k primes.c $(LDFLAGS_M68K)

primes_warpos:
	$(CC) $(CFLAGS_WARPOS) -o primes_warpos primes.c $(LDFLAGS_WARPOS)

clean:
	rm -f window primes_m68k primes_warpos
