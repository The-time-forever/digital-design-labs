#include "mpu6050.h"
#include "config.h"

#include <math.h>
#include <wiringPiI2C.h>

#define MPU6050_PWR_MGMT_1 0x6b
#define MPU6050_ACCEL_XOUT 0x3b

static int16_t read_word_2c(int fd, int reg)
{
    int high = wiringPiI2CReadReg8(fd, reg);
    int low = wiringPiI2CReadReg8(fd, reg + 1);
    int value = (high << 8) | low;

    if (value >= 0x8000)
    {
        value = -((65535 - value) + 1);
    }

    return (int16_t)value;
}

int mpu6050_init(int addr)
{
    int fd = wiringPiI2CSetup(addr);
    if (fd < 0)
    {
        return -1;
    }

    wiringPiI2CWriteReg8(fd, MPU6050_PWR_MGMT_1, 0x00);
    return fd;
}

int mpu6050_read_raw(int fd,
                     int16_t *ax, int16_t *ay, int16_t *az,
                     int16_t *gx, int16_t *gy, int16_t *gz)
{
    if (fd < 0)
    {
        return -1;
    }

    *ax = read_word_2c(fd, MPU6050_ACCEL_XOUT);
    *ay = read_word_2c(fd, MPU6050_ACCEL_XOUT + 2);
    *az = read_word_2c(fd, MPU6050_ACCEL_XOUT + 4);
    // temp is at +6
    *gx = read_word_2c(fd, MPU6050_ACCEL_XOUT + 8);
    *gy = read_word_2c(fd, MPU6050_ACCEL_XOUT + 10);
    *gz = read_word_2c(fd, MPU6050_ACCEL_XOUT + 12);
    return 0;
}

int mpu6050_read_angles(int fd, float *roll_deg, float *pitch_deg)
{
    int16_t ax, ay, az, gx, gy, gz;
    if (mpu6050_read_raw(fd, &ax, &ay, &az, &gx, &gy, &gz) < 0)
    {
        return -1;
    }

    // According to spec:
    // roll  = atan2(ay, az) * 180 / PI;
    // pitch = atan2(-ax, sqrt(ay * ay + az * az)) * 180 / PI;
    const float PI = 3.1415926535f;
    *roll_deg = atan2f((float)ay, (float)az) * 180.0f / PI;
    *pitch_deg = atan2f(-(float)ax, sqrtf((float)ay * ay + (float)az * az)) * 180.0f / PI;

    return 0;
}

int mpu6050_is_tilted(float roll_deg, float pitch_deg)
{
    return (fabs(roll_deg) >= TILT_THRESHOLD_DEG || fabs(pitch_deg) >= TILT_THRESHOLD_DEG);
}
