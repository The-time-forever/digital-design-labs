#ifndef MPU6050_H
#define MPU6050_H

#include <stdint.h>

int mpu6050_init(int addr);
int mpu6050_read_raw(int fd,
                     int16_t *ax, int16_t *ay, int16_t *az,
                     int16_t *gx, int16_t *gy, int16_t *gz);
int mpu6050_read_angles(int fd, float *roll_deg, float *pitch_deg);
int mpu6050_is_tilted(float roll_deg, float pitch_deg);

#endif
