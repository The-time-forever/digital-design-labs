#ifndef ENCODER_H
#define ENCODER_H

int encoder_init(void);
long encoder_get_ticks(void);
void encoder_reset(void);
float encoder_get_mileage_cm(void);

#endif
