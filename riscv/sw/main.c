#include <stdint.h>

#define REG_ADDR_LED    (0x20000000)

void main (void)
{
    uint32_t counter = 0;
    uint32_t led = 0;
    while (1)
    {
        counter+=1;
        if (counter >= 1000000)
        {
            counter = 0;
            led=!led;
            *((uint32_t *) REG_ADDR_LED) = 0x02 | led;
        }
    }
}
