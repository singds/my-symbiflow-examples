#include <stdint.h>

const uint8_t constant = 1;

void main (void)
{
    uint32_t counter = 0;
    uint32_t led = 0;
    while (1)
    {
        volatile const uint8_t *total = &constant;
        counter++;
        if (counter >= *total)
        {
            counter = 0;
            led = !led;
            *((uint32_t *) 0x20000000) = led;
        }
    }
}