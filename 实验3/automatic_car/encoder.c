#include "encoder.h"
#include "config.h"

#include <math.h>
#include <wiringPi.h>

static volatile long encoder_count = 0;

static void encoder_isr(void)
{
    int clk = digitalRead(ENCODER_CLK_PIN);
    int dt = digitalRead(ENCODER_DT_PIN);
    if (clk == dt)
    {
        encoder_count++;
    }
    else
    {
        encoder_count--;
    }
}

static void encoder_sw_isr(void)
{
    static unsigned long last_sw_time = 0;
    unsigned long now = millis();

    /* Debounce: ignore presses within 200ms */
    if (now - last_sw_time < 200)
        return;
    last_sw_time = now;

    /* Reset only when the switch is actually pressed. Respect wiring polarity. */
#if ENCODER_SW_ACTIVE_LOW
    if (digitalRead(ENCODER_SW_PIN) == LOW)
    {
        encoder_count = 0;
    }
#else
    if (digitalRead(ENCODER_SW_PIN) == HIGH)
    {
        encoder_count = 0;
    }
#endif
}

int encoder_init(void)
{
    pinMode(ENCODER_CLK_PIN, INPUT);
    pinMode(ENCODER_DT_PIN, INPUT);
    pinMode(ENCODER_SW_PIN, INPUT);

    pullUpDnControl(ENCODER_CLK_PIN, PUD_UP);
    pullUpDnControl(ENCODER_DT_PIN, PUD_UP);
    pullUpDnControl(ENCODER_SW_PIN, PUD_UP);

    if (wiringPiISR(ENCODER_CLK_PIN, INT_EDGE_BOTH, encoder_isr) < 0)
    {
        return -1;
    }

    /* Use BOTH edges to be more robust; ISR will check for LOW and debounce */
    if (wiringPiISR(ENCODER_SW_PIN, INT_EDGE_BOTH, encoder_sw_isr) < 0)
    {
        return -1;
    }

    return 0;
}

long encoder_get_ticks(void)
{
    return encoder_count;
}

void encoder_reset(void)
{
    encoder_count = 0;
}

float encoder_get_mileage_cm(void)
{
    const float pi = 3.1415926f;
    float wheel_circ = pi * WHEEL_DIAMETER_CM;
    return (encoder_count / (float)ENCODER_PULSES_PER_REV) * wheel_circ;
}
