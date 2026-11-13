#ifndef PCF8591_H
#define PCF8591_H

int pcf8591_init(int addr);
int pcf8591_read_channel(int fd, int channel);

#endif
