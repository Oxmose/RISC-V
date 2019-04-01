#include <iostream>
#include <stdlib.h>     /* srand, rand */
#include <time.h>       /* time */

using namespace std;

int main()
{
    uint32_t random1[10];
    uint32_t random2[10];
    uint32_t result[10];

    srand(time(NULL));

    for(uint32_t i = 1; i < 10; ++i)
    {
        random1[i] = (rand() * rand()) & 0xFFFFF7FF;
        random2[i] = (rand() * rand()) & 0xFFFFF7FF;

        result[i] = random1[i] ^ random2[i];

        cout << "lui x" << i << ", 0x" << hex << (random1[i] >> 12) << dec << endl;
        cout << "lui x" << i + 10 << ", 0x" << hex << (random2[i] >> 12) << dec << endl;
        cout << "lui x" << i + 20 << ", 0x" << hex << (result[i] >> 12) << dec << endl;
    }
    for(uint32_t i = 1; i < 10; ++i)
    {
        cout << "addi x" << i << ", x" << i << ", 0x" << hex << (random1[i] & 0xFFF) << dec << endl;
        cout << "addi x" << i + 10 << ", x" << i + 10 << ", 0x" << hex << (random2[i] & 0xFFF) << dec << endl;
        cout << "addi x" << i + 20 << ", x" << i + 20 << ", 0x" << hex << (result[i] & 0xFFF) << dec << endl;
    }

    for(uint32_t i = 1; i < 10; ++i)
    {
        cout << "xor x" << i << ", x" << i << ", x" << i + 10 << endl;
    }

    for(uint32_t i = 1; i < 10; ++i)
    {
        cout << "bne x" << i << ", x" << i + 20 << ", error\nnop\nnop" << endl;
    }
    return 0;
}
