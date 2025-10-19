#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PRIME 10000000
#define STORE_COUNT 50

/*
 * Sieve of Eratosthenes - Prime Number Calculator
 * Multi-platform example for m68k-amigaos and ppc-warpos
 * Memory-optimized version using bit-level storage
 */

/* Bit manipulation macros for the sieve */
#define GET_BIT(sieve, index) ((sieve[(index) >> 3] >> ((index) & 7)) & 1)
#define SET_BIT(sieve, index) (sieve[(index) >> 3] |= (1 << ((index) & 7)))
#define CLEAR_BIT(sieve, index) (sieve[(index) >> 3] &= ~(1 << ((index) & 7)))

void calculate_primes(int limit, int *first_primes, int *last_primes, int *total_count) {
    unsigned char *sieve;
    int i, j;
    int num_odds = (limit + 1) / 2;  // Number of odd numbers to track
    int sieve_size = (num_odds + 7) / 8;  // Size in bytes (bits packed into bytes)
    int stored_first = 0;
    int stored_last = 0;
    int ring_index = 0;
    
    // Allocate bit-packed sieve for odd numbers only
    sieve = (unsigned char *)malloc(sieve_size);
    if (!sieve) {
        printf("Memory allocation failed!\n");
        *total_count = 0;
        return;
    }
    
    // Initialize sieve - set all bits to 1 (assume all odd numbers are prime)
    memset(sieve, 0xFF, sieve_size);
    
    // Handle 2 separately (the only even prime)
    *total_count = 1;
    first_primes[stored_first++] = 2;
    last_primes[ring_index++] = 2;
    
    // Sieve of Eratosthenes for odd numbers only
    for (i = 3; i * i <= limit; i += 2) {
        if (GET_BIT(sieve, i / 2)) {
            // Mark all odd multiples of i as not prime
            for (j = i * i; j <= limit; j += i * 2) {
                CLEAR_BIT(sieve, j / 2);
            }
        }
    }
    
    // Count and collect primes
    for (i = 3; i <= limit; i += 2) {
        if (GET_BIT(sieve, i / 2)) {
            (*total_count)++;
            
            // Store first STORE_COUNT primes
            if (stored_first < STORE_COUNT) {
                first_primes[stored_first++] = i;
            }
            
            // Store last STORE_COUNT primes in a ring buffer
            last_primes[ring_index] = i;
            ring_index = (ring_index + 1) % STORE_COUNT;
            stored_last++;
        }
    }
    
    // If we found more than STORE_COUNT primes, rotate ring buffer to get last STORE_COUNT in order
    if (stored_last >= STORE_COUNT) {
        int temp[STORE_COUNT];
        for (i = 0; i < STORE_COUNT; i++) {
            temp[i] = last_primes[(ring_index + i) % STORE_COUNT];
        }
        memcpy(last_primes, temp, STORE_COUNT * sizeof(int));
    }
    
    free(sieve);
}

int main(void) {
    int first_primes[STORE_COUNT];
    int last_primes[STORE_COUNT];
    int total_count = 0;
    int i;
    int limit = MAX_PRIME;
    
    printf("===========================================\n");
    printf("  Sieve of Eratosthenes\n");
    printf("  Prime Number Calculator\n");
    printf("  Memory-Optimized (Bit-Packed Sieve)\n");
    printf("===========================================\n\n");
    
    printf("Calculating prime numbers up to %d...\n", limit);
    printf("(Using bit-packed sieve, storing first and last %d primes)\n\n", STORE_COUNT);
    
    // Calculate primes
    calculate_primes(limit, first_primes, last_primes, &total_count);
    
    if (total_count == 0) {
        printf("ERROR: Prime calculation failed!\n");
        return 1;
    }
    
    printf("Found %d prime numbers!\n\n", total_count);
    
    // Display first primes
    printf("First %d prime numbers:\n", STORE_COUNT);
    for (i = 0; i < STORE_COUNT && i < total_count; i++) {
        printf("%10d", first_primes[i]);
        if ((i + 1) % 10 == 0) printf("\n");
    }
    printf("\n");
    
    // Display last primes
    if (total_count > STORE_COUNT) {
        printf("\nLast %d prime numbers found:\n", STORE_COUNT);
        for (i = 0; i < STORE_COUNT; i++) {
            printf("%10d", last_primes[i]);
            if ((i + 1) % 10 == 0) printf("\n");
        }
        printf("\n");
    }
    
    return 0;
}


