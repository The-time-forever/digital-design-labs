.RECIPEPREFIX := >

CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2
LDLIBS = -lwiringPi -lm -lpthread

TARGET = automatic_car

SRCS = main.c lcd1602.c pcf8591.c led.c light.c rain.c ultrasonic.c buzzer.c encoder.c mpu6050.c display.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
>$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

%.o: %.c
>$(CC) $(CFLAGS) -c $< -o $@

clean:
>rm -f $(OBJS) $(TARGET)

rebuild: clean all
