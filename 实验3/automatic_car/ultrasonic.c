#include "ultrasonic.h"
#include "config.h"
#include <wiringPi.h>

void ultrasonic_init(void)
{
    pinMode(ULTRASONIC_TRIG_PIN, OUTPUT);
    pinMode(ULTRASONIC_ECHO_PIN, INPUT);
    digitalWrite(ULTRASONIC_TRIG_PIN, LOW);
    delay(50);
}

float ultrasonic_read_cm(void)
{
    long start_wait;
    long echo_start;
    long echo_end;

    digitalWrite(ULTRASONIC_TRIG_PIN, LOW);
    delayMicroseconds(2);
    digitalWrite(ULTRASONIC_TRIG_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(ULTRASONIC_TRIG_PIN, LOW);

    start_wait = micros();
    while (digitalRead(ULTRASONIC_ECHO_PIN) == LOW)
    {
        if (micros() - start_wait > 30000L)
        {
            return -1.0f; // Timeout
        }
    }
    echo_start = micros();

    while (digitalRead(ULTRASONIC_ECHO_PIN) == HIGH)
    {
        if (micros() - echo_start > 30000L)
        {
            return -1.0f; // Timeout
        }
    }
    echo_end = micros();

    float duration_us = (float)(echo_end - echo_start);
    return duration_us * 0.0343f / 2.0f;
}
