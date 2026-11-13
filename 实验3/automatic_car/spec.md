# Raspberry Pi 4B 车辆传感器综合实验：C + makefile 程序设计说明

## 1. 项目目标

请实现一个 Raspberry Pi 4B 车辆传感器综合实验程序，使用 C 语言、wiringPi、wiringPiI2C 和 makefile。项目需要实现指导书“车辆传感器”场景中的 5 个功能：

1. 自动大灯：通过 PCF8591 板载光敏电阻读取环境亮度，环境暗时点亮 LED。
2. 自动雨刷：通过雨滴传感器数字输出 DO 判断是否有雨水，LCD 显示 `Raining` 或 `No Rain`。
3. 障碍物报警：通过 HC-SR04 超声波传感器测距，距离过近时蜂鸣器报警。
4. 行驶里程计量：通过旋转编码器统计脉冲，计算/显示累计里程。
5. 姿态感知：通过 MPU6050 读取加速度，计算 Roll/Pitch，倾斜过大时报警。

程序应在树莓派上编译和运行。Windows 电脑只用于 VS Code 编写代码，不在 Windows 上编译。

---

## 2. 重要约定

### 2.1 引脚编号方式

本项目使用的是 BCM 编号 T 型转接板，因此代码必须使用：

```c
wiringPiSetupGpio();
```

不要使用：

```c
wiringPiSetup();
```

所有 `#define GPIO_PIN` 都必须写 BCM 编号，和 T 型板上的 `GPIOxx` 标号一致。

---

## 3. 硬件接线表

### 3.1 I2C 总线模块

LCD1602、PCF8591、MPU6050 三个模块共用 I2C 总线。

| 模块               | 模块引脚 | Raspberry Pi 4B / BCM T 型板 |
| ---------------- | ---- | -------------------------- |
| LCD1602 I2C      | GND  | GND                        |
| LCD1602 I2C      | VCC  | 5V                         |
| LCD1602 I2C      | SDA  | GPIO2 / SDA                |
| LCD1602 I2C      | SCL  | GPIO3 / SCL                |
| PCF8591 AD/DA    | GND  | GND                        |
| PCF8591 AD/DA    | VCC  | 3.3V                       |
| PCF8591 AD/DA    | SDA  | GPIO2 / SDA                |
| PCF8591 AD/DA    | SCL  | GPIO3 / SCL                |
| MPU6050 / GY-521 | VCC  | 3.3V                       |
| MPU6050 / GY-521 | GND  | GND                        |
| MPU6050 / GY-521 | SDA  | GPIO2 / SDA                |
| MPU6050 / GY-521 | SCL  | GPIO3 / SCL                |

I2C 地址固定如下：

```c
#define LCD1602_I2C_ADDR        0x27
#define PCF8591_I2C_ADDR        0x48
#define MPU6050_I2C_ADDR        0x68
```

已知 `i2cdetect -y 1` 已扫到 `0x48` 和 `0x68`。LCD 按 `0x27` 编写。

---

### 3.2 自动大灯 LED

使用红色 LED 模块，模块引脚为 `S / + / -`。

| LED 模块 | Raspberry Pi |
| ------ | ------------ |
| S      | GPIO17       |
| +      | 3.3V         |
| -      | GND          |

代码定义：

```c
#define LED_PIN 17
```

---

### 3.3 PCF8591 光敏检测

使用 PCF8591 板载光敏电阻，不使用单独光敏模块。

PCF8591 板载光敏通常对应：

```c
#define LIGHT_ADC_CHANNEL 1
```

即读取 PCF8591 的 AIN1 / INPUT1。

自动大灯逻辑：

```text
读取光敏值 light_value
若环境变暗，则 LED 亮
若环境变亮，则 LED 灭
```

注意：不同模块可能“越暗数值越大”或“越暗数值越小”，所以代码中要提供宏开关，例如：

```c
#define LIGHT_DARK_WHEN_HIGH 1
#define LIGHT_DARK_THRESHOLD 120
```

如果实测发现逻辑反了，只需要改宏，不要改业务代码。

---

### 3.4 雨滴检测

雨滴检测由两部分组成：

1. 雨滴感应板：`MH-RD Raindrops module`
2. 雨滴控制板：引脚为 `AO / VCC / DO / GND`

雨滴感应板两针接到雨滴控制板两针接口。

雨滴控制板接线：

| 雨滴控制板 | Raspberry Pi |
| ----- | ------------ |
| AO    | 暂时不接         |
| VCC   | 3.3V         |
| DO    | GPIO22       |
| GND   | GND          |

代码定义：

```c
#define RAIN_DIGITAL_PIN 22
```

雨滴逻辑使用 DO 数字输入：

```text
DO 电平变化 → 判断是否有雨
有雨 → LCD 显示 Raining
无雨 → LCD 显示 No Rain
```

考虑不同雨滴模块可能低电平有效，需要提供宏：

```c
#define RAIN_ACTIVE_LOW 1
```

---

### 3.5 超声波 HC-SR04

按实验教程直连。

| HC-SR04 | Raspberry Pi |
| ------- | ------------ |
| VCC     | 5V           |
| Trig    | GPIO23       |
| Echo    | GPIO24       |
| GND     | GND          |

代码定义：

```c
#define ULTRASONIC_TRIG_PIN 23
#define ULTRASONIC_ECHO_PIN 24
```

测距逻辑：

```text
Trig 输出 10us 高电平
读取 Echo 高电平持续时间
distance_cm = duration_us * 0.0343 / 2
```

报警逻辑：

```c
#define DIST_WARN_CM    30.0f
#define DIST_DANGER_CM  10.0f
```

```text
distance > 30cm：蜂鸣器不响
10cm < distance <= 30cm：蜂鸣器慢速间歇响
distance <= 10cm：蜂鸣器快速间歇响
```

如果超声波超时，返回 `-1.0f`，表示无效距离。

---

### 3.6 蜂鸣器

蜂鸣器模块引脚为：

```text
I/O / VCC / GND
```

接线：

| 蜂鸣器 | Raspberry Pi  |
| --- | ------------- |
| I/O | GPIO27        |
| VCC | 3.3V，若不响可试 5V |
| GND | GND           |

代码定义：

```c
#define BUZZER_PIN 27
```

考虑不同蜂鸣器模块高/低电平触发不同，提供宏：

```c
#define BUZZER_ACTIVE_HIGH 1
```

---

### 3.7 旋转编码器

旋转编码器模块引脚：

```text
GND / + / SW / DT / CLK
```

接线：

| 编码器 | Raspberry Pi |
| --- | ------------ |
| GND | GND          |
| +   | 3.3V         |
| SW  | GPIO13       |
| DT  | GPIO6        |
| CLK | GPIO5        |

代码定义：

```c
#define ENCODER_CLK_PIN 5
#define ENCODER_DT_PIN  6
#define ENCODER_SW_PIN  13
```

编码器逻辑：

```text
使用 CLK 和 DT 判断旋转方向
顺时针 count++
逆时针 count--
SW 作为可选复位按钮，可以短按清零里程
```

里程换算：

```c
#define ENCODER_PULSES_PER_REV 20
#define WHEEL_DIAMETER_CM      6.5f
```

计算：

```text
wheel_circumference = PI * WHEEL_DIAMETER_CM
mileage_cm = encoder_ticks / ENCODER_PULSES_PER_REV * wheel_circumference
```

如果方向反了，可以在代码中提供宏或直接交换 `CLK/DT` 逻辑。

---

### 3.8 MPU6050 姿态检测

MPU6050 使用 I2C，地址 `0x68`。

读取寄存器：

```text
ACCEL_XOUT_H = 0x3B
ACCEL_YOUT_H = 0x3D
ACCEL_ZOUT_H = 0x3F
GYRO_XOUT_H  = 0x43
GYRO_YOUT_H  = 0x45
GYRO_ZOUT_H  = 0x47
PWR_MGMT_1   = 0x6B
```

初始化时写：

```text
PWR_MGMT_1 = 0x00
```

姿态计算：

```c
roll  = atan2(ay, az) * 180 / PI;
pitch = atan2(-ax, sqrt(ay * ay + az * az)) * 180 / PI;
```

倾斜报警阈值：

```c
#define TILT_THRESHOLD_DEG 35.0f
```

判断：

```text
abs(roll) >= 35 或 abs(pitch) >= 35 → 车辆倾斜报警
```

---

## 4. 推荐工程结构

请生成如下工程结构：

```text
automatic_car/
├── config.h
├── main.c
├── lcd1602.h
├── lcd1602.c
├── pcf8591.h
├── pcf8591.c
├── led.h
├── led.c
├── light.h
├── light.c
├── rain.h
├── rain.c
├── ultrasonic.h
├── ultrasonic.c
├── buzzer.h
├── buzzer.c
├── encoder.h
├── encoder.c
├── mpu6050.h
├── mpu6050.c
├── display.h
├── display.c
└── makefile
```

---

## 5. config.h 设计要求

`config.h` 统一保存所有引脚、I2C 地址、阈值、状态结构体。

必须使用下面这些 BCM 引脚定义：

```c
#ifndef CONFIG_H
#define CONFIG_H

#include <stdint.h>

#define LED_PIN                 17
#define BUZZER_PIN              27
#define RAIN_DIGITAL_PIN        22

#define ULTRASONIC_TRIG_PIN     23
#define ULTRASONIC_ECHO_PIN     24

#define ENCODER_CLK_PIN         5
#define ENCODER_DT_PIN          6
#define ENCODER_SW_PIN          13

#define LCD1602_I2C_ADDR        0x27
#define PCF8591_I2C_ADDR        0x48
#define MPU6050_I2C_ADDR        0x68

#define LIGHT_ADC_CHANNEL       1

#define LED_ACTIVE_HIGH         1
#define BUZZER_ACTIVE_HIGH      1
#define RAIN_ACTIVE_LOW         1
#define LIGHT_DARK_WHEN_HIGH    1

#define LIGHT_DARK_THRESHOLD    120
#define DIST_WARN_CM            30.0f
#define DIST_DANGER_CM          10.0f
#define TILT_THRESHOLD_DEG      35.0f

#define LOOP_DELAY_MS           100
#define DISPLAY_PAGE_MS         2000

#define ENCODER_PULSES_PER_REV  20
#define WHEEL_DIAMETER_CM       6.5f

typedef struct {
    int light_value;
    int light_on;

    int rain_raw;
    int rain_detected;

    float distance_cm;
    int obstacle_detected;
    int alarm_level;

    int16_t accel_x;
    int16_t accel_y;
    int16_t accel_z;
    int16_t gyro_x;
    int16_t gyro_y;
    int16_t gyro_z;

    float roll_deg;
    float pitch_deg;
    int tilt_detected;

    long encoder_ticks;
    float mileage_cm;
} CarStatus;

#endif
```

---

## 6. 各模块文件职责

### 6.1 led.c / led.h

职责：控制自动大灯 LED。

接口：

```c
void led_init(void);
void led_set(int on);
```

要求：

* `led_init()` 设置 `LED_PIN` 为输出。
* `led_set(1)` 点亮 LED。
* `led_set(0)` 熄灭 LED。
* 必须考虑 `LED_ACTIVE_HIGH` 宏。

---

### 6.2 buzzer.c / buzzer.h

职责：控制蜂鸣器报警。

接口：

```c
void buzzer_init(void);
void buzzer_off(void);
void buzzer_set(int on);
void buzzer_task(int alarm_level);
```

要求：

* `alarm_level = 0`：不响。
* `alarm_level = 1`：慢速间歇响。
* `alarm_level = 2`：快速间歇响。
* 必须使用非阻塞方式，不要在 `buzzer_task()` 中长时间 `delay()`。
* 使用 `millis()` 控制定时。
* 必须考虑 `BUZZER_ACTIVE_HIGH` 宏。

---

### 6.3 rain.c / rain.h

职责：读取雨滴控制板 DO。

接口：

```c
void rain_init(void);
int rain_raw_value(void);
int rain_is_detected(void);
```

要求：

* `RAIN_DIGITAL_PIN` 设置为输入。
* 可启用上拉：`pullUpDnControl(RAIN_DIGITAL_PIN, PUD_UP);`
* 根据 `RAIN_ACTIVE_LOW` 判断是否有雨。

---

### 6.4 pcf8591.c / pcf8591.h

职责：读取 PCF8591 模拟量。

接口：

```c
int pcf8591_init(int addr);
int pcf8591_read_channel(int fd, int channel);
```

要求：

* 使用 `wiringPiI2CSetup(addr)`。
* 读取时写控制字 `0x40 | channel`。
* PCF8591 第一次读取是 dummy read，应丢弃第一次读数。
* 返回 0 到 255 的 ADC 值。

---

### 6.5 light.c / light.h

职责：自动大灯判断。

接口：

```c
int light_read_value(int pcf_fd);
int light_is_dark(int value);
```

要求：

* `light_read_value()` 读取 `LIGHT_ADC_CHANNEL`。
* `light_is_dark()` 根据 `LIGHT_DARK_WHEN_HIGH` 和 `LIGHT_DARK_THRESHOLD` 判断是否暗。
* 主程序根据 `light_is_dark()` 控制 LED。

---

### 6.6 ultrasonic.c / ultrasonic.h

职责：读取 HC-SR04 距离。

接口：

```c
void ultrasonic_init(void);
float ultrasonic_read_cm(void);
```

要求：

* Trig 为输出，Echo 为输入。
* Trig 输出 10us 高电平触发测距。
* 使用 `micros()` 测 Echo 高电平持续时间。
* 必须有超时保护，避免程序卡死。
* 超时返回 `-1.0f`。

---

### 6.7 encoder.c / encoder.h

职责：旋转编码器计数和里程换算。

接口：

```c
int encoder_init(void);
long encoder_get_ticks(void);
void encoder_reset(void);
float encoder_get_mileage_cm(void);
```

要求：

* CLK、DT、SW 都设为输入，并启用上拉。
* 用 `wiringPiISR()` 对 CLK 或 CLK+DT 设置中断。
* 根据 CLK/DT 相位判断加减。
* SW 可选：按下时清零。
* 里程根据 `ENCODER_PULSES_PER_REV` 和 `WHEEL_DIAMETER_CM` 计算。

---

### 6.8 mpu6050.c / mpu6050.h

职责：读取 MPU6050 并判断姿态。

接口：

```c
int mpu6050_init(int addr);
int mpu6050_read_raw(int fd,
                     int16_t *ax, int16_t *ay, int16_t *az,
                     int16_t *gx, int16_t *gy, int16_t *gz);
int mpu6050_read_angles(int fd, float *roll_deg, float *pitch_deg);
int mpu6050_is_tilted(float roll_deg, float pitch_deg);
```

要求：

* 初始化时解除睡眠：写 `PWR_MGMT_1 = 0x00`。
* 原始加速度按 ±2g 默认量程换算，比例为 `16384.0f`。
* 计算 roll 和 pitch。
* `abs(roll) >= TILT_THRESHOLD_DEG` 或 `abs(pitch) >= TILT_THRESHOLD_DEG` 判断为倾斜。
* 需要 `#include <math.h>`，makefile 链接 `-lm`。

---

### 6.9 lcd1602.c / lcd1602.h

职责：I2C LCD1602 显示。

接口：

```c
int lcd1602_init(int addr);
void lcd1602_clear(void);
void lcd1602_write_line(int row, const char *text);
void lcd1602_backlight(int on);
```

要求：

* LCD 地址为 `0x27`。
* 支持 16x2 显示。
* `lcd1602_write_line(row, text)` 自动补空格/截断，避免残留字符。
* row=0 表示第一行，row=1 表示第二行。

---

### 6.10 display.c / display.h

职责：统一刷新 LCD 显示。

接口：

```c
void display_update(const CarStatus *status);
```

显示逻辑：

LCD 1602 只有两行，使用轮播页面。

页面 1：

```text
Light:ON L:123
Rain :YES
```

页面 2：

```text
Dist:  25.3cm
Buzz:SLOW
```

页面 3：

```text
Mile:  123.4cm
Pose:Normal
```

报警优先级：

1. 如果距离小于 `DIST_DANGER_CM`，优先显示：

```text
WARNING!
Obstacle Near
```

2. 如果姿态倾斜，优先显示：

```text
WARNING!
Car Tilted
```

3. 其他情况正常轮播。

---

## 7. main.c 主程序逻辑

主程序必须这样组织：

1. 注册 Ctrl+C 信号，退出时关闭蜂鸣器、熄灭 LED、清 LCD。
2. 调用 `wiringPiSetupGpio()`。
3. 初始化 LED、蜂鸣器、雨滴、超声波、编码器。
4. 初始化 LCD1602。
5. 初始化 PCF8591。
6. 初始化 MPU6050。
7. 进入主循环。
8. 主循环每次读取：

   * 光敏值
   * 雨滴状态
   * 超声波距离
   * 编码器 tick 和里程
   * MPU6050 姿态
9. 更新 `CarStatus`。
10. 根据状态控制：

* LED
* 蜂鸣器
* LCD 显示

11. 同时在终端 printf 输出完整调试信息。

主循环伪代码：

```text
while running:
    light_value = light_read_value(pcf_fd)
    light_on = light_is_dark(light_value)
    led_set(light_on)

    rain_raw = rain_raw_value()
    rain_detected = rain_is_detected()

    distance_cm = ultrasonic_read_cm()
    obstacle_detected = distance_cm > 0 && distance_cm <= DIST_WARN_CM

    encoder_ticks = encoder_get_ticks()
    mileage_cm = encoder_get_mileage_cm()

    read MPU6050 raw and roll/pitch
    tilt_detected = mpu6050_is_tilted(roll, pitch)

    alarm_level = 0
    if distance <= DIST_WARN_CM: alarm_level = 1
    if distance <= DIST_DANGER_CM: alarm_level = 2
    if tilt_detected: alarm_level = 2

    buzzer_task(alarm_level)
    display_update(&status)

    printf all status values
    delay(LOOP_DELAY_MS)
```

---

## 8. makefile 要求

生成 `makefile`，目标文件名：

```text
automatic_car
```

编译：

```bash
make
```

运行：

```bash
./automatic_car
```

清理：

```bash
make clean
```

链接库：

```text
-lwiringPi -lm -lpthread
```

推荐 makefile 使用 `.RECIPEPREFIX := >`，避免 Windows/VS Code 里 Tab 被替换为空格导致 makefile 报错。

示例结构：

```makefile
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
```

---

## 9. 调试输出要求

程序运行时终端持续输出一行状态，例如：

```text
Light=123 LED=ON Rain=NO Dist=25.4cm Count=12 Mile=24.5cm Roll=2.1 Pitch=-1.3 Alarm=1
```

必须包含：

* 光敏值
* LED 状态
* 雨滴状态
* 距离
* 编码器计数
* 里程
* roll
* pitch
* alarm_level

---

## 10. 需要预留的调参宏

由于实际模块可能电平相反，必须把这些做成宏：

```c
#define LED_ACTIVE_HIGH         1
#define BUZZER_ACTIVE_HIGH      0
#define RAIN_ACTIVE_LOW         1
#define LIGHT_DARK_WHEN_HIGH    1
```

如果实测发现状态反了，只改 `config.h`，不要改模块实现。

---

## 11. 验收测试步骤

### 11.1 I2C 检查

运行：

```bash
i2cdetect -y 1
```

应能看到：

```text
0x27 LCD1602
0x48 PCF8591
0x68 MPU6050
```

### 11.2 自动大灯

遮住 PCF8591 板载光敏：

```text
光敏值变化
环境暗时 LED 亮
环境亮时 LED 灭
```

若逻辑反了，改 `LIGHT_DARK_WHEN_HIGH` 或 `LED_ACTIVE_HIGH`。

### 11.3 雨滴检测

雨滴板干燥：

```text
LCD 显示 No Rain
```

雨滴板滴水或用湿手触碰：

```text
LCD 显示 Raining
```

若逻辑反了，改 `RAIN_ACTIVE_LOW`。

### 11.4 超声波报警

手靠近 HC-SR04：

```text
距离 < 30cm：蜂鸣器慢响
距离 < 10cm：蜂鸣器快响
```

### 11.5 编码器里程

旋转编码器：

```text
encoder_ticks 增加或减少
mileage_cm 随之变化
```

按下 SW：

```text
可选功能：清零里程
```

### 11.6 姿态感知

倾斜 MPU6050：

```text
Roll/Pitch 改变
倾斜超过 35 度时 LCD 显示 Car Tilted
蜂鸣器快速报警
```

---

## 12. 注意事项

1. 不要在 Windows 上编译，代码传到树莓派后再 `make`。
2. 所有 GPIO 编号必须使用 BCM 编号。
3. `main()` 中 GPIO 初始化必须使用 `wiringPiSetupGpio()`。
4. LCD、PCF8591、MPU6050 都走 I2C，SDA/SCL 共用。
5. LCD 地址固定使用 `0x27`。
6. PCF8591 地址固定使用 `0x48`。
7. MPU6050 地址固定使用 `0x68`。
8. PCF8591 板载光敏优先读取 AIN1。
9. 雨滴传感器先用 DO，不用 AO。
10. 代码应模块化，不要把所有逻辑堆在一个 main.c。
11. makefile 要能一键编译所有模块。
12. 程序退出时必须关闭蜂鸣器和 LED。
