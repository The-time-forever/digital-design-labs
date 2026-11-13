#include "display.h"
#include "lcd1602.h"

#include <stdio.h>
#include <wiringPi.h>

void display_update(const CarStatus *status)
{
    static unsigned long last_page_change = 0;
    static int current_page = 0;
    char line1[17];
    char line2[17];
    unsigned long now = millis();

    if (status == 0)
        return;

    // Check high-priority alerts
    if (status->distance_cm > 0.0f && status->distance_cm <= DIST_DANGER_CM)
    {
        lcd1602_write_line(0, "WARNING!");
        lcd1602_write_line(1, "Obstacle Near");
        return;
    }

    if (status->tilt_detected)
    {
        lcd1602_write_line(0, "WARNING!");
        lcd1602_write_line(1, "Car Tilted");
        return;
    }

    // Carousel pages
    if (now - last_page_change >= DISPLAY_PAGE_MS)
    {
        last_page_change = now;
        current_page = (current_page + 1) % 3;
    }

    switch (current_page)
    {
    case 0:
        snprintf(line1, sizeof(line1), "Light:%s L:%d", status->light_on ? "ON " : "OFF", status->light_value);
        snprintf(line2, sizeof(line2), "Rain :%s", status->rain_detected ? "YES" : "NO");
        break;
    case 1:
        if (status->distance_cm < 0.0f)
        {
            snprintf(line1, sizeof(line1), "Dist:  ERR cm");
        }
        else
        {
            snprintf(line1, sizeof(line1), "Dist:  %.1fcm", status->distance_cm);
        }

        const char *buzz_msg = "OFF";
        if (status->alarm_level == 1)
            buzz_msg = "SLOW";
        else if (status->alarm_level == 2)
            buzz_msg = "FAST";
        snprintf(line2, sizeof(line2), "Buzz:%s", buzz_msg);
        break;
    case 2:
        snprintf(line1, sizeof(line1), "Mile:  %.1fcm", status->mileage_cm);
        snprintf(line2, sizeof(line2), "Pose:%s", status->tilt_detected ? "Tilted" : "Normal");
        break;
    }

    lcd1602_write_line(0, line1);
    lcd1602_write_line(1, line2);
}
