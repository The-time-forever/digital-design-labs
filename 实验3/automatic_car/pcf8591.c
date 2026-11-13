#include "pcf8591.h"
#include <wiringPiI2C.h>

int pcf8591_init(int addr)
{
    return wiringPiI2CSetup(addr);
}

int pcf8591_read_channel(int fd, int channel)
{
    int control;

    if (fd < 0 || channel < 0 || channel > 3)
    {
        return -1;
    }

    control = 0x40 | (channel & 0x03);
    wiringPiI2CWrite(fd, control);
    (void)wiringPiI2CRead(fd); /* dummy read */
    return wiringPiI2CRead(fd) & 0xff;
}
