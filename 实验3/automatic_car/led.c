#include "led.h"
#include "config.h"
#include <wiringPi.h>

void led_init(void)
{
    pinMode(LED_PIN, OUTPUT);
    led_set(0);
}

void led_set(int on)
{
    int state = on ? (LED_ACTIVE_HIGH ? HIGH : LOW) : (LED_ACTIVE_HIGH ? LOW : HIGH);
    digitalWrite(LED_PIN, state);
}
