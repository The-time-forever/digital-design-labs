#include "light.h"
#include "config.h"
#include "pcf8591.h"

int light_read_value(int pcf_fd)
{
    return pcf8591_read_channel(pcf_fd, LIGHT_ADC_CHANNEL);
}

int light_is_dark(int value)
{
    if (value < 0)
    {
        return 0;
    }

    if (LIGHT_DARK_WHEN_HIGH)
    {
        return value > LIGHT_DARK_THRESHOLD;
    }
    else
    {
        return value < LIGHT_DARK_THRESHOLD;
    }
}
