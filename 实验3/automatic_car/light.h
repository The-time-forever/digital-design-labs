#ifndef LIGHT_H
#define LIGHT_H

int light_read_value(int pcf_fd);
int light_is_dark(int value);

#endif
