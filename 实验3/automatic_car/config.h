#ifndef CONFIG_H
#define CONFIG_H

#include <stdint.h>

#define LED_PIN 17
#define BUZZER_PIN 27
#define RAIN_DIGITAL_PIN 22

#define ULTRASONIC_TRIG_PIN 23
#define ULTRASONIC_ECHO_PIN 24

#define ENCODER_CLK_PIN 5
#define ENCODER_DT_PIN 6
#define ENCODER_SW_PIN 13
/* Encoder switch active level: set 1 if switch pulls LOW when pressed */
#define ENCODER_SW_ACTIVE_LOW 1

#define LCD1602_I2C_ADDR 0x27
#define PCF8591_I2C_ADDR 0x48
#define MPU6050_I2C_ADDR 0x68

#define LIGHT_ADC_CHANNEL 1

#define LED_ACTIVE_HIGH 1
#define BUZZER_ACTIVE_HIGH 0
#define RAIN_ACTIVE_LOW 1
#define LIGHT_DARK_WHEN_HIGH 1

#define LIGHT_DARK_THRESHOLD 120
#define DIST_WARN_CM 30.0f
#define DIST_DANGER_CM 10.0f
#define TILT_THRESHOLD_DEG 35.0f

#define LOOP_DELAY_MS 100
#define DISPLAY_PAGE_MS 2000

#define ENCODER_PULSES_PER_REV 20
#define WHEEL_DIAMETER_CM 6.5f

typedef struct
{
    int light_value;
    int light_on;

    int rain_raw;
    int rain_detected;

    float distance_cm;
    int obstacle_detected;
    int alarm_level;

    int16_t accel_x;
    int16_t accel_y;
    int16_t accel_z;
    int16_t gyro_x;
    int16_t gyro_y;
    int16_t gyro_z;

    float roll_deg;
    float pitch_deg;
    int tilt_detected;

    long encoder_ticks;
    float mileage_cm;
} CarStatus;

#endif
