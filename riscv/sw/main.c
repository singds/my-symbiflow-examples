#include <stdint.h>

void main (void)
{
    uint32_t counter = 0;
    uint32_t led = 0;
    while (1)
    {
        counter++;
        if (counter >= 1000000)
        {
            counter = 0;
            led = !led;
            *((uint32_t *) 0x20000000) = led;
        }
    }
}