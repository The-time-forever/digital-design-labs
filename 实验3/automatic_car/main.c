#include "config.h"
#include "buzzer.h"
#include "display.h"
#include "encoder.h"
#include "led.h"
#include "light.h"
#include "mpu6050.h"
#include "pcf8591.h"
#include "rain.h"
#include "ultrasonic.h"
#include "lcd1602.h"

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <wiringPi.h>

static int running = 1;
static int pcf_fd = -1;
static int mpu_fd = -1;

void handle_sigint(int sig)
{
    (void)sig;
    running = 0;
}

static void cleanup(void)
{
    buzzer_off();
    led_set(0);
    lcd1602_clear();
}

int main(void)
{
    CarStatus status = {0};

    signal(SIGINT, handle_sigint);

    if (wiringPiSetupGpio() < 0)
    {
        fprintf(stderr, "wiringPiSetupGpio failed\n");
        return 1;
    }

    led_init();
    buzzer_init();
    rain_init();
    ultrasonic_init();
    encoder_init();

    if (lcd1602_init(LCD1602_I2C_ADDR) < 0)
    {
        fprintf(stderr, "lcd1602_init failed\n");
    }

    pcf_fd = pcf8591_init(PCF8591_I2C_ADDR);
    if (pcf_fd < 0)
    {
        fprintf(stderr, "pcf8591_init failed\n");
    }

    mpu_fd = mpu6050_init(MPU6050_I2C_ADDR);
    if (mpu_fd < 0)
    {
        fprintf(stderr, "mpu6050_init failed\n");
    }

    while (running)
    {
        status.light_value = light_read_value(pcf_fd);
        status.light_on = light_is_dark(status.light_value);
        led_set(status.light_on);

        status.rain_raw = rain_raw_value();
        status.rain_detected = rain_is_detected();

        status.distance_cm = ultrasonic_read_cm();
        status.obstacle_detected = (status.distance_cm > 0 && status.distance_cm <= DIST_WARN_CM);

        status.encoder_ticks = encoder_get_ticks();
        status.mileage_cm = encoder_get_mileage_cm();

        mpu6050_read_angles(mpu_fd, &status.roll_deg, &status.pitch_deg);
        status.tilt_detected = mpu6050_is_tilted(status.roll_deg, status.pitch_deg);

        status.alarm_level = 0;
        if (status.distance_cm > 0 && status.distance_cm <= DIST_WARN_CM)
        {
            status.alarm_level = 1;
        }
        if (status.distance_cm > 0 && status.distance_cm <= DIST_DANGER_CM)
        {
            status.alarm_level = 2;
        }
        if (status.tilt_detected)
        {
            status.alarm_level = 2;
        }

        buzzer_task(status.alarm_level);
        display_update(&status);

        printf("Light=%d LED=%s Rain=%s Dist=%.1fcm Count=%ld Mile=%.1fcm Roll=%.1f Pitch=%.1f Alarm=%d\n",
               status.light_value,
               status.light_on ? "ON" : "OFF",
               status.rain_detected ? "YES" : "NO",
               status.distance_cm,
               status.encoder_ticks,
               status.mileage_cm,
               status.roll_deg,
               status.pitch_deg,
               status.alarm_level);

        delay(LOOP_DELAY_MS);
    }

    cleanup();
    return 0;
}
