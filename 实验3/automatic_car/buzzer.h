#ifndef BUZZER_H
#define BUZZER_H

void buzzer_init(void);
void buzzer_off(void);
void buzzer_set(int on);
void buzzer_task(int alarm_level);

#endif
