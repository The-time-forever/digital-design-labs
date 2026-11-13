#ifndef LCD1602_H
#define LCD1602_H

int lcd1602_init(int addr);
void lcd1602_clear(void);
void lcd1602_write_line(int row, const char *text);
void lcd1602_backlight(int on);

#endif
