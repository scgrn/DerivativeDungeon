#include "random.h"

#include <time.h>

typedef struct {
    unsigned int x;
    unsigned int y;
} RandomState;

static RandomState state = {2282008U, 362436069U};

static unsigned int randomUint32() {
    state.x = 69069U * state.x + 123U;
    state.y ^= state.y << 13U;
    state.y ^= state.y >> 17U;
    state.y ^= state.y << 5U;

    return state.x + state.y;
}

void rndSeedTime() {
    unsigned int t = time(NULL);
    unsigned int f = 0;

    //  flip bits
    for (int i = 0; i < 32; i++) {
        f |= ((t >> i) & 1) << (31-i);
    }

    rndSeed(f);
}

void rndSeed(unsigned int seed) {
    state.x = seed;
    state.y = 362436069U;
}

double rndDouble() {
    return randomUint32() * (1.0 / 4294967296.0); // 2 ^ 32 − 1
}

unsigned int rndInt(unsigned int n) {
    return (unsigned int)(rndDouble() * (double)n);
}

int rndIntRange(int lb, int ub) {
  return lb + (unsigned int)(rndDouble() * (ub - lb + 1));
}
