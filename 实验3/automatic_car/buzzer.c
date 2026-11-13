#include "buzzer.h"
#include "config.h"

#include <wiringPi.h>

void buzzer_init(void)
{
    pinMode(BUZZER_PIN, OUTPUT);
    buzzer_off();
}

void buzzer_set(int on)
{
    int state = on ? (BUZZER_ACTIVE_HIGH ? HIGH : LOW) : (BUZZER_ACTIVE_HIGH ? LOW : HIGH);
    digitalWrite(BUZZER_PIN, state);
}

void buzzer_off(void)
{
    buzzer_set(0);
}

void buzzer_task(int alarm_level)
{
    static unsigned long last_time = 0;
    static int state = 0;
    unsigned long now = millis();
    int interval = 0;

    if (alarm_level == 0)
    {
        buzzer_off();
        state = 0;
        return;
    }
    else if (alarm_level == 1)
    {
        interval = 500; // slow
    }
    else if (alarm_level == 2)
    {
        interval = 100; // fast
    }

    if (now - last_time >= (unsigned long)interval)
    {
        last_time = now;
        state = !state;
        buzzer_set(state);
    }
}
