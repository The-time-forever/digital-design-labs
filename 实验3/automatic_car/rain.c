#include "rain.h"
#include "config.h"
#include <wiringPi.h>

void rain_init(void)
{
    pinMode(RAIN_DIGITAL_PIN, INPUT);
    pullUpDnControl(RAIN_DIGITAL_PIN, PUD_UP);
}

int rain_raw_value(void)
{
    return digitalRead(RAIN_DIGITAL_PIN);
}

int rain_is_detected(void)
{
    int val = rain_raw_value();
    return RAIN_ACTIVE_LOW ? (val == LOW) : (val == HIGH);
}
