/**
    Xorshift PRNG
    11.28.18
*/

#ifndef RANDOM_H
#define RANDOM_H

void rndSeedTime();
void rndSeed(unsigned int seed);

double rndDouble();
unsigned int rndInt(unsigned int n);
int rndIntRange(int lb, int ub);

#endif // RANDOM_H
