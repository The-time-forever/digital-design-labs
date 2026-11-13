#include "lcd1602.h"
#include <stdio.h>
#include <string.h>
#include <wiringPi.h>
#include <wiringPiI2C.h>

#define LCD_BACKLIGHT 0x08
#define LCD_ENABLE 0x04
#define LCD_RS 0x01

static int lcd_fd = -1;
static int backlight = LCD_BACKLIGHT;

static void lcd_write_raw(int data)
{
    wiringPiI2CWrite(lcd_fd, data | backlight);
}

static void lcd_pulse(int data)
{
    lcd_write_raw(data | LCD_ENABLE);
    delayMicroseconds(1);
    lcd_write_raw(data & ~LCD_ENABLE);
    delayMicroseconds(50);
}

static void lcd_write4(int nibble, int mode)
{
    int data = (nibble & 0xf0) | mode;
    lcd_write_raw(data);
    lcd_pulse(data);
}

static void lcd_send(int value, int mode)
{
    lcd_write4(value & 0xf0, mode);
    lcd_write4((value << 4) & 0xf0, mode);
}

static void lcd_command(int value)
{
    lcd_send(value, 0);
}

static void lcd_data(int value)
{
    lcd_send(value, LCD_RS);
}

static void lcd1602_set_cursor(int col, int row)
{
    static const int row_offsets[] = {0x00, 0x40};
    if (row < 0)
        row = 0;
    else if (row > 1)
        row = 1;
    if (col < 0)
        col = 0;
    else if (col > 15)
        col = 15;

    lcd_command(0x80 | (col + row_offsets[row]));
}

int lcd1602_init(int addr)
{
    lcd_fd = wiringPiI2CSetup(addr);
    if (lcd_fd < 0)
    {
        return -1;
    }

    delay(50);
    lcd_write4(0x30, 0);
    delay(5);
    lcd_write4(0x30, 0);
    delayMicroseconds(150);
    lcd_write4(0x30, 0);
    lcd_write4(0x20, 0);

    lcd_command(0x28);
    lcd_command(0x0c);
    lcd_command(0x06);
    lcd1602_clear();
    return 0;
}

void lcd1602_clear(void)
{
    lcd_command(0x01);
    delay(2);
}

void lcd1602_write_line(int row, const char *text)
{
    char buffer[17];
    int len;
    int i;

    memset(buffer, ' ', 16);
    buffer[16] = '\0';

    if (text != 0)
    {
        len = (int)strlen(text);
        if (len > 16)
            len = 16;
        memcpy(buffer, text, len);
    }

    lcd1602_set_cursor(0, row);
    for (i = 0; i < 16; ++i)
    {
        lcd_data((unsigned char)buffer[i]);
    }
}

void lcd1602_backlight(int on)
{
    backlight = on ? LCD_BACKLIGHT : 0x00;
    lcd_write_raw(0);
}
