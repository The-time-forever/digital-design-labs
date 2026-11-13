> From: https://chatgpt.com/c/6a1d6cf1-10cc-83ea-809a-f856c86242e0

# you asked

message time: 2026-06-01 04:29:12

这个文档前面的网络连接系统太老了，我用的win10系统，请你教学一下

---

# chatgpt response

可以。你这个文档前面用的是 Win7 风格的“本地连接 / 本地连接 2 / 网络和共享中心”，但核心思路没变：**电脑通过 Wi-Fi/有线网上网，然后把网络共享给 USB 网卡；USB 网卡再用网线直连树莓派。** 文档里对应的是 USB 网卡、网络共享、192.168.137.1、`arp -a` 查树莓派 IP、PuTTY SSH 登录这些步骤。

## Win10 版操作流程

### 1. 先接线

你的连接方式应该是：

```text
电脑 Wi-Fi / 电脑原本的网口  ← 负责上网
电脑 USB 网卡  ← 网线直连 →  树莓派网口
```

也就是说，不是把树莓派直接接路由器，而是让电脑给树莓派“共享网络”。

---

### 2. 打开 Win10 的网络适配器页面

最推荐用这个方法，别从“设置”里慢慢找：

按 `Win + R`，输入：

```text
ncpa.cpl
```

回车。

会打开一个窗口，里面能看到类似这些东西：

```text
WLAN / Wi-Fi
以太网
以太网 2
```

一般来说：

| 旧文档叫法 | Win10 里可能显示 |
|---|---|
| 本地连接 | Wi-Fi / WLAN / 以太网 |
| 本地连接 2 | 以太网 2 / USB Ethernet / ASIX / Realtek USB |

你要分清两个网卡：

**能上网的那个**：通常是 Wi-Fi。  
**接树莓派的那个**：通常是 USB 网卡，可能显示“以太网 2”或“未识别的网络”。

---

### 3. 给树莓派共享网络

在 `ncpa.cpl` 界面中：

右键你电脑当前正在上网的那个网络，比如：

```text
Wi-Fi
```

然后点：

```text
属性 → 共享
```

勾选：

```text
允许其他网络用户通过此计算机的 Internet 连接来连接
```

下面如果有“家庭网络连接”的下拉框，就选择你的 USB 网卡，比如：

```text
以太网 2
```

然后点确定。

成功后，Win10 通常会自动把 USB 网卡设置成：

```text
IP 地址：192.168.137.1
子网掩码：255.255.255.0
```

这个和文档里的 `192.168.137.1` 是一致的，只是 Win10 界面名字变了。

---

### 4. 检查 USB 网卡 IP 是否正确

还是在 `ncpa.cpl` 界面：

右键接树莓派的那个 USB 网卡，比如：

```text
以太网 2
```

点：

```text
属性 → Internet 协议版本 4 TCP/IPv4 → 属性
```

正常情况下应该看到它被设置成：

```text
IP 地址：192.168.137.1
子网掩码：255.255.255.0
默认网关：空
DNS：空
```

如果不是，也可以手动设置成这样。

注意，**这个 IP 是电脑 USB 网卡的 IP，不是树莓派的 IP。**

---

### 5. 启动树莓派，等待 1 到 2 分钟

插好树莓派电源，网线也接好。

等一会儿，让树莓派启动并获取 IP。

---

### 6. 查树莓派 IP

打开 CMD 或 PowerShell，输入：

```bash
ipconfig
```

先确认你的 USB 网卡是不是：

```text
IPv4 地址 . . . . . . . . . . . : 192.168.137.1
```

然后输入：

```bash
arp -a
```

找类似：

```text
192.168.137.10
192.168.137.XX
```

文档里提到，有些实验镜像会把树莓派固定成：

```text
192.168.137.10
```

所以你可以优先试这个地址。

---

### 7. 用 SSH 连接树莓派

Win10 可以不用 PuTTY，直接用 CMD/PowerShell：

```bash
ssh pi@192.168.137.10
```

如果不行，就把 IP 换成你 `arp -a` 查到的地址：

```bash
ssh pi@192.168.137.xx
```

老实验镜像一般是：

```text
用户名：pi
密码：raspberry
```

输入密码时，屏幕不会显示星号，也不会显示字符，这是正常的，输完回车就行。

如果你用 PuTTY：

```text
Host Name: 192.168.137.10
Port: 22
Connection type: SSH
```

然后 Open。

---

## 如果连不上，按这个顺序排查

### 情况 1：共享选项找不到

可能你点错网卡了。

你应该右键的是**正在上网的网卡**，比如 Wi-Fi，不是 USB 网卡。

如果 USB 网卡里面已经开了共享，先把 USB 网卡的共享关掉，再去 Wi-Fi 里开启共享。

---

### 情况 2：开启共享时报错

按 `Win + R`，输入：

```text
services.msc
```

找到并启动这两个服务：

```text
Windows Defender Firewall
Internet Connection Sharing (ICS)
```

然后重新打开网络共享。

文档里也提到，旧系统下如果共享报错，需要开启 Windows Firewall 和 ICS 服务，这个在 Win10 里仍然适用。

---

### 情况 3：`arp -a` 找不到树莓派

先直接试：

```bash
ssh pi@192.168.137.10
```

因为实验镜像可能已经固定了这个 IP。

还不行的话，试：

```bash
ping 192.168.137.10
```

如果完全不通，检查：

```text
1. 树莓派是否通电
2. 网线是否插紧
3. USB 网卡灯是否亮
4. Win10 的 USB 网卡是否是 192.168.137.1
5. 网络共享是不是共享给了正确的“以太网 2”
```

如果你电脑开了 VPN、TUN、代理软件，也建议先关掉。很多代理/TUN 会改 Windows 路由，导致共享网络异常。

---

### 情况 4：SSH 提示密码错误

如果是学校给的老镜像，大概率是：

```text
pi / raspberry
```

但如果你自己烧的是新版 Raspberry Pi OS，新版系统可能没有默认 `pi` 用户，也不默认开启 SSH。那就需要用 Raspberry Pi Imager 重新设置用户名、密码和开启 SSH。

---

## 最简单总结

你在 Win10 上照这个来：

```text
Win + R → ncpa.cpl
右键正在上网的 Wi-Fi → 属性 → 共享
勾选允许共享 → 选择 USB 网卡/以太网 2
确认 USB 网卡变成 192.168.137.1
CMD 输入 arp -a
找 192.168.137.xx
ssh pi@192.168.137.10
密码 raspberry
```

你可以先直接试：

```bash
ssh pi@192.168.137.10
```

如果出现：

```text
login as:
```

或者要求输入密码，就说明网络已经通了。

---

# you asked

message time: 2026-06-01 04:53:08

OK了，我双色实验也做好了；接下来做要求的实验，我选择做车辆传感器，你有什么需要我提供的信息吗（先别急着写代码）

---

# chatgpt response

可以，先不写代码。你现在最好先把**硬件、接线、目标功能范围**确认清楚，不然后面代码很容易写完跑不起来。

文档里“车辆传感器”要求大致包括：光敏自动大灯、雨滴检测、超声波障碍报警、旋转编码器里程计、陀螺仪/加速度姿态感知这几块。

你需要先给我这些信息：

## 1. 你打算做完整 5 个功能，还是做其中几个？

先确认老师要求：

```text
A. 必须 5 个功能都做
B. 做 3 个左右就可以
C. 做一个综合演示就行
```

如果没有硬性要求，我建议先做这个顺序：

```text
1. 光敏传感器 → LED 自动大灯
2. 雨滴传感器 → LCD 显示 Raining
3. 超声波传感器 → 蜂鸣器报警
4. 旋转编码器 → LCD 显示里程
5. MPU6050 → 姿态/侧翻报警
```

前三个最容易做成稳定演示，后两个相对麻烦。

---

## 2. 你手头有哪些模块？

你直接把模块列一下，或者拍一张套件照片也行。重点确认有没有这些：

| 功能 | 需要模块 |
|---|---|
| 自动大灯 | 光敏传感器、LED/RGB灯 |
| 自动雨刷 | 雨滴传感器、LCD屏 |
| 障碍物报警 | 超声波模块、蜂鸣器 |
| 里程计量 | 旋转编码器、LCD屏 |
| 姿态感知 | MPU6050 陀螺仪/加速度传感器、蜂鸣器 |

尤其要确认：

```text
LCD 是不是 1602 I2C 液晶屏？
AD/DA 模块是不是 PCF8591？
超声波是不是 HC-SR04？
姿态传感器是不是 MPU6050？
```

---

## 3. 你现在已经会用哪些模块的例程？

比如你可以告诉我：

```text
双色 LED 已经跑通
LCD 还没测
光敏还没测
雨滴还没测
超声波还没测
蜂鸣器还没测
MPU6050 还没测
旋转编码器还没测
```

这个很重要。后面最好是**先单模块测试，再合并工程**，不要一上来就写综合代码。

---

## 4. 把你的接线表发我

后面写综合代码最怕 GPIO 对不上。

你可以按这个格式填：

```text
光敏传感器：
VCC 接：
GND 接：
AO/DO 接：

雨滴传感器：
VCC 接：
GND 接：
AO/DO 接：

超声波：
VCC 接：
GND 接：
Trig 接：
Echo 接：

蜂鸣器：
VCC 接：
GND 接：
Signal 接：

LCD：
VCC 接：
GND 接：
SDA 接：
SCL 接：

旋转编码器：
CLK/A 接：
DT/B 接：
SW 接：
+ 接：
GND 接：

MPU6050：
VCC 接：
GND 接：
SDA 接：
SCL 接：
```

如果你还没接线，也可以先发你手头的模块，我帮你规划接线，尽量避免 GPIO 冲突。

---

## 5. 你用的是哪种显示方式？

车辆传感器最好有个“输出界面”，你选一个：

```text
A. 只在终端 printf 显示
B. LCD 显示状态
C. 终端 + LCD 都显示
```

我建议选 **C**。调试时终端方便，验收时 LCD 更直观。

---

## 6. 你希望最终演示效果是什么？

比如可以设计成：

```text
环境变暗 → LED 自动亮
雨滴板有水 → LCD 显示 Raining
前方距离小于 20cm → 蜂鸣器快速响
旋转编码器转动 → LCD 显示里程数
板子倾斜过大 → 蜂鸣器报警 / LCD 显示 Tilt
```

你可以告诉我老师验收时看什么，是“功能能跑”就行，还是要有比较完整的场景展示。

---

## 7. 你项目文件打算怎么组织？

后面有两种做法：

```text
方案一：所有功能写在一个 automatic_car.c 里面
优点：简单，适合快速验收
缺点：代码比较乱

方案二：每个模块一个 .c/.h，最后用 makefile 编译
优点：规范，适合交实验报告
缺点：前期麻烦一点
```

如果时间紧，我建议先用**一个主文件跑通**；确认没问题后，再整理成多文件 + makefile。

---

你现在先回复我这 4 个最关键的信息就够了：

```text
1. 老师要求几个功能？必须全做吗？
2. 你手头有哪些模块？
3. LCD、超声波、蜂鸣器、光敏、雨滴这些例程有没有单独跑通过？
4. 你现在有没有已经确定的接线？有的话发接线表/照片。
```

拿到这些以后，我们再开始设计整体方案，仍然可以先不写代码。

---

# you asked

message time: 2026-06-01 04:55:30

文档提到的都要做，先把文档上的MVP做出来

---

# chatgpt response

可以，那我们就按**文档“车辆传感器”里的 5 个功能都做**，但先做一个**最小可验收 MVP**：功能先全部跑起来，界面和代码结构先不追求很漂亮。

文档里的车辆传感器包括：自动大灯、自动雨刷、障碍物报警、行驶里程计量、姿态感知；常见问题里还特别提醒了电压、`WiringPiSetup()`、AD 模块通道、LCD 地址等注意事项，这些后面都要按它来。

## MVP 目标先定成这样

### 1. 自动大灯

用光敏传感器读取环境亮度。

MVP 效果：

```text
环境暗 → LED 亮
环境亮 → LED 灭
```

先不做复杂 PWM 调光，只做开关。

---

### 2. 自动雨刷

用雨滴传感器检测有没有水。

MVP 效果：

```text
检测到雨水 → LCD 显示 Raining
没有雨水 → LCD 显示 No Rain
```

这里不一定真的接电机模拟雨刷，文档要求里核心是通过雨滴传感器判断并在 LCD 显示状态，所以 MVP 先这样做。

---

### 3. 障碍物报警

用超声波测距离，用蜂鸣器报警。

MVP 效果：

```text
距离 > 30cm → 不响
10cm ~ 30cm → 慢速响
距离 < 10cm → 快速响
```

这样验收时很直观，手靠近超声波，蜂鸣器频率变快。

---

### 4. 行驶里程计量

用旋转编码器统计转动次数。

MVP 效果：

```text
转动编码器 → 计数增加/减少
LCD 或终端显示 Mileage / Count
```

一开始可以先不换算真实厘米数，直接显示脉冲数 `count`。如果老师要求“里程”，后面再设一个换算系数，比如：

```text
mileage = pulse_count × 每个脉冲对应距离
```

---

### 5. 姿态感知

用 MPU6050 或类似陀螺仪/加速度传感器判断倾斜。

MVP 效果：

```text
板子水平 → Normal
倾斜角度过大 → Tilt / Alarm
```

可以用蜂鸣器报警，也可以 LCD 显示 `Tilt!`。

---

## 我建议的 MVP 总体结构

先不要一上来写很多 `.c/.h` 文件，容易乱。第一版用：

```text
automatic_car.c
makefile
```

也就是**一个主程序先跑通全部功能**。等 MVP 跑通后，再拆成：

```text
light.c / light.h
rain.c / rain.h
ultrasonic.c / ultrasonic.h
encoder.c / encoder.h
mpu6050.c / mpu6050.h
lcd.c / lcd.h
automatic_car.c
makefile
```

这样更适合最后交报告。

---

## 推荐接线思路

先按 **wiringPi 编号**来规划，因为你前面的双色 LED 例程就是这种风格。注意：文档里类似 `GPIO0 → GPIO17` 的写法，本质上就是 wiringPi 编号和 BCM 编号的对应关系。

我先给你一个**不冲突的推荐方案**，后面你可以按你手头模块微调：

| 模块 | 功能 | 推荐接法 |
|---|---|---|
| LCD1602 I2C | 显示状态 | SDA/SCL 接树莓派 I2C |
| PCF8591 AD/DA | 读取光敏模拟值 | SDA/SCL 接树莓派 I2C |
| 光敏传感器 | 自动大灯 | 接 PCF8591 的 AIN1 |
| 雨滴传感器 | 检测雨水 | DO 接 wiringPi 6 |
| LED / RGB灯 | 自动大灯 | R 或普通 LED 接 wiringPi 0 |
| 蜂鸣器 | 报警 | Signal 接 wiringPi 2 |
| 超声波 Trig | 发射触发 | wiringPi 4 |
| 超声波 Echo | 回波输入 | wiringPi 5 |
| 旋转编码器 A | 计数 A 相 | wiringPi 21 |
| 旋转编码器 B | 计数 B 相 | wiringPi 22 |
| MPU6050 | 姿态检测 | SDA/SCL 接树莓派 I2C |

I2C 上可以同时挂多个设备，比如 LCD、PCF8591、MPU6050，因为它们地址不同。常见地址大概是：

```text
LCD1602 I2C：0x27
PCF8591：0x48
MPU6050：0x68
```

你后面可以用这个命令检查：

```bash
i2cdetect -y 1
```

能扫到这些地址，说明 I2C 大概率没问题。

---

## 先做 MVP 的调试顺序

不要五个模块一起接完再测。建议按这个顺序来：

```text
第 1 步：LCD 单独显示 Hello
第 2 步：光敏传感器读取数值，控制 LED
第 3 步：雨滴传感器检测，LCD 显示 Raining
第 4 步：超声波测距，终端显示距离
第 5 步：蜂鸣器根据距离报警
第 6 步：旋转编码器计数
第 7 步：MPU6050 读取倾角
第 8 步：整合成 automatic_car.c
```

这样最稳。否则出问题时不知道是接线、I2C、代码还是模块本身的问题。

---

## 你现在需要先给我这几样东西

你不用急着拍很完整，先确认关键信息：

```text
1. 你手头有没有 LCD1602 I2C 屏？
2. 光敏传感器是接 AD/DA 模块的那种，还是单独一个模块有 AO/DO？
3. 雨滴传感器有没有 DO 引脚？
4. 超声波是不是 HC-SR04？
5. 姿态传感器是不是 MPU6050？
6. 旋转编码器是三针的，还是五针的？引脚上写的是 CLK/DT/SW/+/GND 吗？
```

最省事的方法是：你把所有车辆传感器相关模块摆一起拍一张图，再拍一下每个模块的引脚字样。我根据你的实际模块，把最终接线表定下来，然后再开始写 MVP 代码。

---

# you asked

message time: 2026-06-01 04:58:19

我用的是树莓派4B，有接转接T型板，用C写还是Python写，打算用makefie来完成

---

# chatgpt response

建议你这个实验**用 C 写，不要用 Python**。

原因很简单：这个指导书本身就是按 **C + wiringPi + gcc + makefile** 这套路线设计的。前面的双色 LED 实验也是 `gcc xxx.c -o xxx -lwiringPi`，后面的车辆传感器综合实验还专门讲了 makefile 的写法，所以你继续用 C 最稳，和老师给的例程、实验报告、验收方式都一致。

## 推荐方案

你现在的路线应该定成：

```text
树莓派 4B + T 型转接板
C 语言
wiringPi 编号
makefile 编译
多文件模块化
```

也就是最终工程大概长这样：

```text
automatic_car/
├── main.c
├── led.c
├── led.h
├── light.c
├── light.h
├── rain.c
├── rain.h
├── ultrasonic.c
├── ultrasonic.h
├── buzzer.c
├── buzzer.h
├── encoder.c
├── encoder.h
├── mpu6050.c
├── mpu6050.h
├── lcd.c
├── lcd.h
└── makefile
```

不过第一版 MVP 不一定一开始就拆这么细。可以先这样：

```text
automatic_car/
├── main.c
├── lcd.c
├── lcd.h
├── ultrasonic.c
├── ultrasonic.h
├── encoder.c
├── encoder.h
├── mpu6050.c
├── mpu6050.h
└── makefile
```

光敏、雨滴、蜂鸣器、LED 这些比较简单的，第一版可以先直接写在 `main.c` 里，等跑通后再拆。

## 为什么不建议 Python

Python 的优点是写起来快，但是你这个实验不太适合：

```text
1. 文档例程是 C，不是 Python
2. 老师给的模块代码大概率也是 C
3. makefile 更适合 C 工程
4. wiringPi 的 GPIO 编号和指导书更容易对应
5. 交报告时 C + makefile 看起来更符合“嵌入式系统设计专题实验”
```

如果你用 Python，后面 LCD、PCF8591、MPU6050、红外/编码器这些库可能都要重新找，反而麻烦。

## 编号方式要注意

你用了 T 型转接板，所以后面接线时一定要统一一种编号方式。

指导书里经常写这种形式：

```text
GPIO0 → GPIO17
GPIO1 → GPIO18
```

这里左边的 `GPIO0 / GPIO1` 通常是 **wiringPi 编号**，右边的 `GPIO17 / GPIO18` 是树莓派 BCM 编号。

所以后面我给你写代码时，建议统一按：

```text
wiringPi 编号
```

比如：

```c
#define LED_PIN 0
```

这通常对应 BCM GPIO17，也就是 T 型板上标的 GPIO17。

## MVP 第一阶段建议

你说“先做文档上的 MVP”，那就这样定：

| 功能 | MVP 实现方式 |
|---|---|
| 自动大灯 | 光敏传感器检测亮暗，控制 LED 亮灭 |
| 自动雨刷 | 雨滴传感器检测有水，LCD 显示 `Raining` |
| 障碍物报警 | 超声波测距，距离近时蜂鸣器报警 |
| 行驶里程计量 | 旋转编码器计数，LCD/终端显示 count |
| 姿态感知 | MPU6050 检测倾斜，倾斜过大报警 |

先不要加太多花活，比如 PWM 调光、真实轮径换算、复杂菜单、红外遥控切换显示，这些等 MVP 跑通后再加。

## 接下来我需要你确认两件事

第一，你手上的模块是不是这些：

```text
LCD1602 I2C 屏
PCF8591 AD/DA 模块
光敏传感器
雨滴传感器
HC-SR04 超声波
有源蜂鸣器
旋转编码器
MPU6050
普通 LED 或 RGB LED
```

第二，你把 T 型板和模块引脚照片发我，尤其是每个模块上写的：

```text
VCC / GND / S / DO / AO / TRIG / ECHO / CLK / DT / SDA / SCL
```

然后我先帮你定一份**不冲突的接线表**，再写 makefile 和 C 代码。这样最稳。

---

# you asked

message time: 2026-06-01 05:00:27

不要第一版了，直接朝着最终版做

---

# chatgpt response

可以，那我们就不做“临时大杂烩版”，直接按**最终可提交工程**来设计：**C 语言 + wiringPi + 多文件模块化 + makefile + LCD 综合显示 + 车辆传感器五功能全部实现**。

文档要求的车辆传感器包括：自动大灯、自动雨刷、障碍物报警、行驶里程计量、姿态感知；文档后面也专门讲了 makefile 的组织方式，所以最终版就按这个路线走。

## 最终工程目标

最终效果设计成这样：

| 功能 | 传感器/模块 | 最终效果 |
|---|---|---|
| 自动大灯 | 光敏传感器 + LED/RGB 灯 | 光线暗时自动开灯，亮时关灯 |
| 自动雨刷 | 雨滴传感器 + LCD | 检测到雨水，LCD 显示 `Raining` |
| 障碍物报警 | 超声波 + 蜂鸣器 | 距离越近，蜂鸣器报警越急 |
| 行驶里程 | 旋转编码器 + LCD | 编码器转动，实时累计里程/脉冲数 |
| 姿态感知 | MPU6050 | 倾斜/侧翻时报警并显示状态 |

## 最终工程目录

后面我建议直接做成这个结构：

```text
automatic_car/
├── main.c
├── config.h
├── lcd1602.c
├── lcd1602.h
├── pcf8591.c
├── pcf8591.h
├── light.c
├── light.h
├── rain.c
├── rain.h
├── ultrasonic.c
├── ultrasonic.h
├── buzzer.c
├── buzzer.h
├── encoder.c
├── encoder.h
├── mpu6050.c
├── mpu6050.h
├── display.c
├── display.h
└── makefile
```

这里面：

```text
config.h        统一管理所有引脚、阈值、I2C 地址
main.c          主循环，整合全部功能
lcd1602         LCD 显示驱动
pcf8591         AD/DA 模块读取
light           自动大灯
rain            雨滴检测
ultrasonic      超声波测距
buzzer          蜂鸣器报警
encoder         旋转编码器计数
mpu6050         姿态检测
display         统一 LCD 界面刷新
makefile        一键编译
```

这样代码不会乱，最后交实验报告也更像一个完整项目。

## 最终运行方式

树莓派里进入项目目录后：

```bash
make
```

生成：

```bash
automatic_car
```

运行：

```bash
./automatic_car
```

清理：

```bash
make clean
```

编译时大概率需要链接这些库：

```bash
-lwiringPi -lm -lpthread
```

如果你的气压/其他 I2C 库不用，这里暂时不加 `-li2c`。车辆传感器这边主要是 wiringPi、数学库和线程库。

## 最终 LCD 显示设计

LCD1602 只有两行，所以不能一次显示全部内容。我建议最终做**轮播显示**，比如每 2 秒切换一页：

第 1 页：

```text
Light: ON/OFF
Rain : YES/NO
```

第 2 页：

```text
Dist : 25.4 cm
Buzz : SLOW/FAST
```

第 3 页：

```text
Mileage: 123
Pose: Normal
```

如果检测到危险状态，比如距离太近、倾斜过大、下雨，可以优先显示报警页：

```text
WARNING!
Obstacle Near
```

或者：

```text
WARNING!
Car Tilted
```

这样演示效果会比较完整。

## 最终接线策略

你用了树莓派 4B + T 型转接板，所以我们后面统一用 **wiringPi 编号**。因为文档里的例程就是这种风格，例如 `GPIO0` 对应树莓派 BCM `GPIO17`。

我先给你一个最终版推荐分配，后面根据你模块实际引脚微调：

| 模块 | 引脚 | wiringPi 编号 | 说明 |
|---|---|---:|---|
| LED 大灯 | LED_PIN | 0 | 对应 BCM17 |
| 蜂鸣器 | BUZZER_PIN | 2 | 对应 BCM27 |
| 雨滴传感器 DO | RAIN_PIN | 3 | 数字输入 |
| 超声波 Trig | TRIG_PIN | 4 | 输出 |
| 超声波 Echo | ECHO_PIN | 5 | 输入 |
| 编码器 A/CLK | ENCODER_A | 21 | 中断输入 |
| 编码器 B/DT | ENCODER_B | 22 | 方向判断 |
| LCD1602 | SDA/SCL | I2C | 地址通常 0x27 |
| PCF8591 | SDA/SCL | I2C | 地址通常 0x48 |
| MPU6050 | SDA/SCL | I2C | 地址通常 0x68 |
| 光敏传感器 | AIN1 | PCF8591 | 模拟输入 |

注意电压：文档常见问题里提醒，光敏、AD/DA、蜂鸣器、温度等一般接 3.3V；超声波、LCD 等接 5V；加速度传感器建议接 3.3V 更安全。

## 最终程序逻辑

主程序大概会这样运行：

```text
1. wiringPiSetup()
2. 初始化 LCD
3. 初始化 PCF8591
4. 初始化雨滴传感器
5. 初始化 LED
6. 初始化超声波
7. 初始化蜂鸣器
8. 初始化旋转编码器中断
9. 初始化 MPU6050
10. 进入 while(1) 主循环
```

主循环里不断做：

```text
读取光敏值 → 判断是否开灯
读取雨滴状态 → 判断是否 Raining
读取超声波距离 → 控制蜂鸣器报警频率
读取编码器累计值 → 换算/显示里程
读取 MPU6050 加速度 → 判断是否倾斜
刷新 LCD 页面
终端 printf 输出完整状态
```

## 我接下来需要你确认的关键信息

既然直接做最终版，下面这些信息必须准确，不然后面代码引脚可能对不上。

你先确认这几个：

```text
1. LCD 是不是 I2C LCD1602？背面有没有小板，4 个引脚 VCC/GND/SDA/SCL？
2. AD/DA 模块是不是 PCF8591？板子上有没有 AIN0、AIN1、AIN2、AIN3？
3. 光敏传感器你打算接 AD 模块的 AIN 几？如果没定，我默认 AIN1。
4. 雨滴传感器你用 AO 还是 DO？最终版建议用 DO，简单稳定。
5. 超声波是不是 HC-SR04？有没有 Trig/Echo？
6. 蜂鸣器是有源蜂鸣器还是无源蜂鸣器？
7. 旋转编码器引脚是不是 CLK、DT、SW、+、GND？
8. MPU6050 是不是 GY-521 那种，VCC/GND/SCL/SDA？
```

你可以直接拍一张所有模块的照片，尤其把每个模块上的引脚字样拍清楚。确认之后，我就可以按最终版给你出：**完整接线表 + config.h + 全部 .c/.h + makefile**。

---

# you asked

message time: 2026-06-01 05:05:56

T型板是BCM编码

---

# chatgpt response

对，这个信息很关键。既然你的 **T 型板是 BCM 编码**，那我们后面代码就不要再用 wiringPi 编号了，直接统一用 **BCM 编号**，这样接线和代码能一一对应。

也就是说，后面程序初始化不要用普通的：

```c
wiringPiSetup();
```

而是用：

```c
wiringPiSetupGpio();
```

这样代码里的：

```c
#define LED_PIN 17
```

就表示你 T 型板上标的 **GPIO17**，不会再绕成 wiringPi 的 `0`。

指导书前面双色 LED 例程里 `GPIO0 → GPIO17` 那种写法，其实左边是 wiringPi 编号，右边才是 BCM 编号；你现在的 T 型板既然直接标 BCM，我们就按 BCM 写，避免混乱。指导书也提醒了主函数开始位置要先初始化 wiringPi，这个原则保留，只是我们换成 BCM 初始化方式。

## 最终版统一规则

后面整个项目统一成：

```text
树莓派 4B
T 型板 BCM 编码
C 语言
wiringPiSetupGpio()
makefile
多文件模块化
```

代码里所有引脚都按 T 型板上的 `GPIOxx` 写。

---

## 推荐 BCM 接线分配

先给你一版比较稳的最终接线规划：

| 功能 | 模块引脚 | 树莓派 BCM GPIO | T 型板标号 |
|---|---|---:|---|
| 自动大灯 LED | Signal / R | GPIO17 | GPIO17 |
| 蜂鸣器 | Signal | GPIO27 | GPIO27 |
| 雨滴传感器 | DO | GPIO22 | GPIO22 |
| 超声波 | Trig | GPIO23 | GPIO23 |
| 超声波 | Echo | GPIO24 | GPIO24 |
| 旋转编码器 | CLK / A | GPIO5 | GPIO5 |
| 旋转编码器 | DT / B | GPIO6 | GPIO6 |
| 旋转编码器 | SW，可选 | GPIO13 | GPIO13 |
| LCD1602 I2C | SDA | GPIO2 | SDA / GPIO2 |
| LCD1602 I2C | SCL | GPIO3 | SCL / GPIO3 |
| PCF8591 AD/DA | SDA | GPIO2 | SDA / GPIO2 |
| PCF8591 AD/DA | SCL | GPIO3 | SCL / GPIO3 |
| MPU6050 | SDA | GPIO2 | SDA / GPIO2 |
| MPU6050 | SCL | GPIO3 | SCL / GPIO3 |
| 光敏传感器 | AO | PCF8591 AIN1 | AIN1 |

I2C 模块可以共用 GPIO2 和 GPIO3，因为 LCD、PCF8591、MPU6050 是通过不同 I2C 地址区分的。

常见地址大概是：

```text
LCD1602 I2C：0x27
PCF8591：0x48
MPU6050：0x68
```

后面可以用：

```bash
i2cdetect -y 1
```

确认有没有扫出来。

---

## 注意几个坑

### 1. 超声波 Echo 要特别注意

HC-SR04 一般 VCC 接 5V，但 Echo 输出也是 5V。

树莓派 GPIO 只能吃 3.3V，所以 Echo 最好经过分压：

```text
HC-SR04 Echo → 分压电阻 → GPIO24
```

常见分压可以用：

```text
Echo -- 1kΩ -- GPIO24 -- 2kΩ -- GND
```

不建议 Echo 直接怼 GPIO24。

---

### 2. 雨滴模块 DO 也要注意电压

如果雨滴模块 VCC 接 5V，它的 DO 可能也是 5V，不安全。

建议：

```text
雨滴传感器 VCC 接 3.3V
DO 接 GPIO22
```

如果你的模块必须 5V 才稳定，就 DO 也要分压。

---

### 3. I2C 设备全部挂在 SDA/SCL 上

LCD、PCF8591、MPU6050 都走：

```text
SDA → GPIO2
SCL → GPIO3
```

不要给它们另外分配普通 GPIO。

指导书里也提到，LCD 地址一般是 `0x27`，原始例程可能写的是 `0x3F`，如果 LCD 不显示，需要改地址或调背板电位器。

---

## config.h 后面就按这种风格写

比如最终会统一成：

```c
#define LED_PIN        17
#define BUZZER_PIN     27
#define RAIN_PIN       22
#define ULTRASONIC_TRIG 23
#define ULTRASONIC_ECHO 24
#define ENCODER_A       5
#define ENCODER_B       6
#define ENCODER_SW      13
```

然后 `main.c` 里初始化：

```c
wiringPiSetupGpio();
```

这样你看到 T 型板上哪个 GPIO，就能直接对应代码里的数字。

---

所以现在我们已经确定：**最终版全部用 BCM 编号写。**

下一步你只需要确认一下模块是不是这些：LCD1602 I2C、PCF8591、光敏、雨滴、HC-SR04、蜂鸣器、旋转编码器、MPU6050。确认后我就可以按 BCM 编号给你出完整接线表和工程代码。

---

# chatgpt response

看照片，你这套模块基本够做“车辆传感器”最终版了。能认出来的有：

```text
光敏传感器模块
蜂鸣器模块
HC-SR04 超声波模块
雨滴传感器控制板 + 雨滴板
PCF8591 AD/DA 模块
MPU6050 / GY-521 姿态传感器
I2C LCD1602 液晶屏
树莓派 4B 的 BCM 编码 T 型转接板
```

文档里车辆传感器要求的五项：自动大灯、自动雨刷、障碍物报警、行驶里程计量、姿态感知；你现在照片里只差一个我没明显看到的：**旋转编码器模块**。如果你盒子里还有一个写着 `CLK / DT / SW / + / GND` 的小模块，那就齐了。

## 先按最终版硬件分配

既然你的 T 型板是 BCM 编码，代码里就全部用 BCM 编号，并用：

```c
wiringPiSetupGpio();
```

不要用 `wiringPiSetup()`。

### 推荐接线表

| 模块 | 模块引脚 | 接树莓派/T 型板 |
|---|---|---|
| LCD1602 I2C | VCC | 5V |
| LCD1602 I2C | GND | GND |
| LCD1602 I2C | SDA | GPIO2 / SDA |
| LCD1602 I2C | SCL | GPIO3 / SCL |
| PCF8591 AD/DA | VCC | 3.3V |
| PCF8591 AD/DA | GND | GND |
| PCF8591 AD/DA | SDA | GPIO2 / SDA |
| PCF8591 AD/DA | SCL | GPIO3 / SCL |
| 光敏传感器 | AO | PCF8591 的 AIN1 |
| 光敏传感器 | VCC | 3.3V |
| 光敏传感器 | GND | GND |
| 雨滴控制板 | VCC | 3.3V |
| 雨滴控制板 | GND | GND |
| 雨滴控制板 | DO | GPIO22 |
| 雨滴板 | 两根线 | 接雨滴控制板的两针接口 |
| HC-SR04 | VCC | 5V |
| HC-SR04 | GND | GND |
| HC-SR04 | Trig | GPIO23 |
| HC-SR04 | Echo | 分压后接 GPIO24 |
| 蜂鸣器 | VCC / + | 3.3V 或 5V，看模块标注 |
| 蜂鸣器 | GND / - | GND |
| 蜂鸣器 | S / I/O | GPIO27 |
| MPU6050 / GY-521 | VCC | 3.3V |
| MPU6050 / GY-521 | GND | GND |
| MPU6050 / GY-521 | SDA | GPIO2 / SDA |
| MPU6050 / GY-521 | SCL | GPIO3 / SCL |
| 旋转编码器 | + | 3.3V |
| 旋转编码器 | GND | GND |
| 旋转编码器 | CLK / A | GPIO5 |
| 旋转编码器 | DT / B | GPIO6 |
| 旋转编码器 | SW | GPIO13，可选 |
| 自动大灯 LED | S / R | GPIO17 |
| 自动大灯 LED | VCC/GND | 按模块标注接 |

## 两个特别重要的地方

### 1. 超声波 Echo 不要直接接 GPIO24

HC-SR04 的 Echo 通常是 5V 输出，树莓派 GPIO 只能承受 3.3V。建议加分压：

```text
Echo ---- 1kΩ ---- GPIO24 ---- 2kΩ ---- GND
```

或者用现成电平转换模块。

### 2. I2C 模块可以共用 SDA/SCL

你的 LCD1602、PCF8591、MPU6050 都是 I2C 设备，所以它们都接：

```text
SDA → GPIO2
SCL → GPIO3
```

不是每个模块单独占一个 GPIO。后面用地址区分：

```text
LCD1602：常见 0x27，也可能 0x3F
PCF8591：常见 0x48
MPU6050：常见 0x68
```

上电后先跑：

```bash
i2cdetect -y 1
```

如果能看到 `27`、`48`、`68`，说明三大 I2C 模块基本在线。文档里也提到 LCD 常见地址是 `0x27`，如果不显示要检查地址或调背面的蓝色电位器。

## 最终工程的 `config.h` 就可以这样规划

```c
#ifndef CONFIG_H
#define CONFIG_H

// BCM GPIO 编号，T 型板上看到多少，这里就写多少
#define LED_PIN             17
#define BUZZER_PIN          27
#define RAIN_DO_PIN         22

#define ULTRASONIC_TRIG_PIN 23
#define ULTRASONIC_ECHO_PIN 24

#define ENCODER_A_PIN       5
#define ENCODER_B_PIN       6
#define ENCODER_SW_PIN      13

// I2C 地址
#define LCD_ADDR            0x27
#define PCF8591_ADDR        0x48
#define MPU6050_ADDR        0x68

// PCF8591 通道
#define LIGHT_CHANNEL       1

// 阈值，后面按实测调整
#define LIGHT_DARK_THRESHOLD 120
#define DIST_WARN_CM         30.0
#define DIST_DANGER_CM       10.0
#define TILT_THRESHOLD_DEG   35.0

#endif
```

这个不是最终完整代码，只是先把硬件规划固定下来。

## 现在你下一步先做这三件事

第一，确认有没有旋转编码器模块。没有的话，行驶里程计量这一项没法按文档完整做。

第二，按上面的 I2C 接法先接 LCD、PCF8591、MPU6050，然后运行：

```bash
i2cdetect -y 1
```

把结果发我。这个结果决定 LCD 地址是不是 `0x27`，以及 PCF8591、MPU6050 是否正常在线。

第三，告诉我蜂鸣器模块上引脚具体写的是不是：

```text
S / + / -
```

或者：

```text
I/O / VCC / GND
```

因为你照片里的蜂鸣器模块有点被遮住了，接反可能不响。确认这三点后，就可以正式开始写最终版工程代码。

---

# you asked

message time: 2026-06-01 05:10:57

第三个是I/O / VCC / GND；那要不一个一个来测试和弄

---

# chatgpt response

对，**一个一个测试再合并**是最稳的。我们就按“最终版工程”的思路做，但每个模块先单独验证，确认没问题后再放进总工程。文档里的车辆传感器功能比较多，直接全接全写很容易不知道是哪一块出错。

你这个蜂鸣器是：

```text
I/O / VCC / GND
```

那它大概率是**有源蜂鸣器模块**，先从它开始测试，最简单。

## 测试顺序建议

我们按这个顺序来：

```text
1. 蜂鸣器测试
2. LCD1602 I2C 测试
3. PCF8591 + 光敏测试
4. 雨滴传感器测试
5. 超声波 HC-SR04 测试
6. 旋转编码器测试
7. MPU6050 姿态测试
8. 最后整合 makefile 工程
```

先从 **蜂鸣器** 开始。

---

# 第 1 步：蜂鸣器单独测试

## 接线

蜂鸣器模块：

| 蜂鸣器模块 | 树莓派 T 型板 |
|---|---|
| I/O | GPIO27 |
| VCC | 3.3V |
| GND | GND |

先用 **3.3V**，更安全。如果不响，再考虑接 5V，但 I/O 仍然接 GPIO27。

---

## 新建测试目录

在树莓派里输入：

```bash
mkdir -p ~/automatic_car_test/buzzer_test
cd ~/automatic_car_test/buzzer_test
```

创建文件：

```bash
nano buzzer_test.c
```

粘贴下面代码：

```c
#include <stdio.h>
#include <wiringPi.h>

#define BUZZER_PIN 27   // BCM GPIO27

int main(void)
{
    if (wiringPiSetupGpio() == -1)
    {
        printf("wiringPi setup failed!\n");
        return 1;
    }

    pinMode(BUZZER_PIN, OUTPUT);

    printf("Buzzer test start...\n");
    printf("Buzzer ON/OFF every 0.5 second.\n");
    printf("Press Ctrl + C to stop.\n");

    while (1)
    {
        digitalWrite(BUZZER_PIN, HIGH);
        delay(500);

        digitalWrite(BUZZER_PIN, LOW);
        delay(500);
    }

    return 0;
}
```

保存：`Ctrl + O`，回车，`Ctrl + X`。

---

## 编译运行

```bash
gcc buzzer_test.c -o buzzer_test -lwiringPi
./buzzer_test
```

正常效果：

```text
蜂鸣器 响 0.5 秒
蜂鸣器 停 0.5 秒
循环重复
```

停止程序：

```text
Ctrl + C
```

---

## 如果不响，按这个排查

### 1. 试反一下高低电平

有些模块是低电平触发。把代码里的这一段：

```c
digitalWrite(BUZZER_PIN, HIGH);
delay(500);

digitalWrite(BUZZER_PIN, LOW);
delay(500);
```

改成：

```c
digitalWrite(BUZZER_PIN, LOW);
delay(500);

digitalWrite(BUZZER_PIN, HIGH);
delay(500);
```

再编译运行。

---

### 2. 确认你真的接的是 GPIO27

你 T 型板是 BCM 编码，所以代码里：

```c
#define BUZZER_PIN 27
```

对应的就是 T 型板上的：

```text
G27 / GPIO27
```

不是 wiringPi 的 27。

---

### 3. VCC 改 5V 试一下

如果 3.3V 不响，可以这样接：

| 蜂鸣器模块 | 树莓派 T 型板 |
|---|---|
| I/O | GPIO27 |
| VCC | 5V |
| GND | GND |

一般这种模块的 I/O 只是控制信号，VCC 接 5V 问题不大。不过先用 3.3V 是更稳妥的。

---

你先把蜂鸣器这一步测完。回复我其中一种结果：

```text
1. 高电平触发，响了
2. 低电平触发，响了
3. 3.3V 不响，5V 响
4. 怎么都不响
```

然后我们继续做第 2 步：LCD1602 I2C 显示测试。

---

# you asked

message time: 2026-06-01 05:11:51

别急着写代码，先确认好信息啊

---

# chatgpt response

对，你提醒得对，先**确认信息和接线方案**，不急着写代码。

你这张图是**旋转编码器模块**，也就是文档里“行驶里程计量”要用的模块。它的引脚看起来是：

```text
GND   +   SW   DT   CLK
```

所以车辆传感器这五项现在基本齐了：光敏、雨滴、超声波、蜂鸣器、旋转编码器、MPU6050、LCD。文档要求里“车辆传感器”确实包括自动大灯、自动雨刷、障碍物报警、行驶里程计量、姿态感知这几项。

## 先确认最终模块分工

我建议按下面这样定：

| 功能 | 模块 | 实现方式 |
|---|---|---|
| 自动大灯 | 光敏传感器 + LED/RGB灯 | 光线暗，LED亮 |
| 自动雨刷 | 雨滴板 + 雨滴控制板 + LCD | 检测到雨水，LCD显示 Raining |
| 障碍物报警 | HC-SR04 + 蜂鸣器 | 距离越近，蜂鸣器越急 |
| 行驶里程计量 | 旋转编码器 | 转动时累计 count / mileage |
| 姿态感知 | MPU6050 | 倾斜过大报警 |

## 旋转编码器先这样定

因为你的 T 型板是 **BCM 编号**，所以接线建议：

| 编码器引脚 | 接树莓派 T 型板 |
|---|---|
| GND | GND |
| + | 3.3V |
| SW | GPIO13，可选 |
| DT | GPIO6 |
| CLK | GPIO5 |

这里 `CLK` 和 `DT` 用来判断转动方向，`SW` 是按下旋钮的按钮，不是必须用。MVP/最终版都可以先不用 SW，只用 `CLK + DT` 做里程计数。

## 现在不要全部接满，先确认 4 件事

### 1. 光敏你准备用哪种方式？

你照片里有两种可能：

```text
A. 单独的光敏模块：VCC/GND/AO/DO
B. PCF8591 板子上自带光敏电阻
```

最终版建议用 **PCF8591 读取模拟值**，这样可以设置亮暗阈值，比 DO 更灵活。

你确认一下：你打算用**单独光敏模块接 PCF8591 的 AIN1**，还是直接用 **PCF8591 板载光敏**？

---

### 2. 你有没有普通 LED 或 RGB LED 模块？

自动大灯需要一个“灯”。

你之前做过双色 LED，应该有 LED 模块。确认一下准备用哪个：

```text
A. 普通 LED
B. 双色 LED
C. RGB LED
D. 直接用已有双色 LED 的其中一个颜色当大灯
```

我建议用 **双色 LED 的红色或绿色其中一路**，简单稳定。

---

### 3. I2C 设备先不要乱接，先确认地址

LCD、PCF8591、MPU6050 都走 I2C：

```text
SDA → GPIO2
SCL → GPIO3
```

但是它们地址要确认。后面测试前，你需要运行：

```bash
i2cdetect -y 1
```

理想情况能看到：

```text
0x27 或 0x3f：LCD
0x48：PCF8591
0x68：MPU6050
```

LCD 地址如果不是 `0x27`，后面代码要改。

---

### 4. 超声波 Echo 要不要分压？

这个必须确认。HC-SR04 的 Echo 通常是 5V，树莓派 GPIO 是 3.3V。

安全接法是：

```text
Echo → 分压 → GPIO24
```

常见分压：

```text
Echo -- 1kΩ -- GPIO24 -- 2kΩ -- GND
```

你手头有没有电阻？比如 1k、2k、10k、20k 都可以配。没有的话，先别测超声波 Echo，避免烧 GPIO。

## 暂定最终接线总表

先只作为规划，别急着全接：

| 模块 | 引脚 | BCM 接法 |
|---|---|---|
| LCD1602 | SDA/SCL | GPIO2/GPIO3 |
| PCF8591 | SDA/SCL | GPIO2/GPIO3 |
| MPU6050 | SDA/SCL | GPIO2/GPIO3 |
| 自动大灯 LED | Signal | GPIO17 |
| 蜂鸣器 | I/O | GPIO27 |
| 雨滴控制板 | DO | GPIO22 |
| 超声波 | Trig | GPIO23 |
| 超声波 | Echo | 分压后 GPIO24 |
| 编码器 | CLK | GPIO5 |
| 编码器 | DT | GPIO6 |
| 编码器 | SW | GPIO13，可选 |

你现在先回复我这四个就行：

```text
1. 自动大灯用哪个 LED 模块？
2. 光敏用单独光敏模块，还是用 PCF8591 板载光敏？
3. 你有没有分压电阻，用来接 HC-SR04 Echo？
4. 树莓派上运行 i2cdetect -y 1 的结果是什么？
```

---

# you asked

message time: 2026-06-01 05:14:38

LED用这个；没有分压电阻

---

# chatgpt response

可以，这个 LED 模块可以用来做“自动大灯”。

你现在已经确认了两个关键信息：

```text
自动大灯 LED：用这个红色 LED 模块
光敏模块：你手上有 AO / DO / GND / VCC 那种
超声波：暂时没有分压电阻
```

## 1. LED 模块可以这样规划

你这个 LED 模块看起来是带板载电阻的模块，不是裸 LED，所以可以直接接 GPIO 控制。

先按这个接法规划：

| LED 模块 | 树莓派 BCM T 型板 |
|---|---|
| S / I/O | GPIO17 |
| + / VCC | 3.3V |
| - / GND | GND |

如果你的模块三个针脚上写的是：

```text
S   +   -
```

那就非常明确：`S` 接 GPIO17，`+` 接 3.3V，`-` 接 GND。

自动大灯逻辑就是：

```text
光线暗 → GPIO17 输出高/低电平 → LED 亮
光线亮 → LED 灭
```

至于它是高电平亮还是低电平亮，后面单独测一下就知道。

---

## 2. 光敏模块建议先用 AO，不用 DO

你这个光敏模块有：

```text
AO / DO / GND / VCC
```

最终版我建议用 **AO 模拟输出**，接到 PCF8591 的 AIN1。这样可以读到 0~255 的亮度数值，再自己设阈值，比 DO 更好调。

规划接法：

| 光敏模块 | 接法 |
|---|---|
| VCC | 3.3V |
| GND | GND |
| AO | PCF8591 AIN1 |
| DO | 暂时不接 |

PCF8591 再接 I2C：

| PCF8591 | 树莓派 BCM T 型板 |
|---|---|
| VCC | 3.3V |
| GND | GND |
| SDA | GPIO2 / SDA |
| SCL | GPIO3 / SCL |

---

## 3. 没有分压电阻的话，超声波先不要接 Echo

这个很重要：**HC-SR04 的 Echo 不建议直接接树莓派 GPIO。**

HC-SR04 通常 VCC 接 5V，Echo 输出也是 5V；树莓派 GPIO 只能承受 3.3V。没有分压电阻或电平转换模块时，先别测超声波 Echo，避免烧 GPIO。

所以障碍物报警这一块暂时有两个选择：

| 选择 | 建议 |
|---|---|
| 先跳过超声波，测试其他模块 | 推荐 |
| 先买/找分压电阻再测 | 推荐 |
| Echo 直接接 GPIO24 | 不推荐 |

你需要准备两个电阻，常见组合都行：

```text
1kΩ + 2kΩ
或者 10kΩ + 20kΩ
```

分压接法是：

```text
HC-SR04 Echo → 1kΩ/10kΩ → GPIO24 → 2kΩ/20kΩ → GND
```

文档里车辆传感器要求有“障碍物报警”，但我们可以等电阻到位后再做这一项，先把其他四项测通。

---

## 4. 现在最终硬件规划更新为这样

| 功能 | 模块 | 接法状态 |
|---|---|---|
| 自动大灯 | 光敏 AO + PCF8591 + 红色 LED | 可以做 |
| 自动雨刷 | 雨滴板 + 雨滴控制板 + LCD | 可以做 |
| 障碍物报警 | HC-SR04 + 蜂鸣器 | 需要分压电阻后再做 |
| 行驶里程 | 旋转编码器 | 可以做 |
| 姿态感知 | MPU6050 | 可以做 |
| 显示 | LCD1602 I2C | 可以做 |

---

## 5. 下一步不要写代码，先做硬件确认

我建议你现在先确认 **I2C 总线**，因为 LCD、PCF8591、MPU6050 都要用它。

你先只接这三个模块的 I2C：

```text
LCD1602
PCF8591
MPU6050
```

统一接：

```text
SDA → GPIO2 / SDA
SCL → GPIO3 / SCL
VCC → 按模块要求接 3.3V 或 5V
GND → GND
```

然后在树莓派运行：

```bash
i2cdetect -y 1
```

把结果发我。

理想情况下应该看到类似：

```text
27  或  3f   ← LCD
48          ← PCF8591
68          ← MPU6050
```

这个结果出来后，我们就能确定后面 LCD、光敏、姿态传感器的地址，不会盲写代码。

---

# you asked

message time: 2026-06-01 05:20:14

超声波直接连就行，教程也是这样的；确认总线这个是哪三个模块，怎么接（按教程那样给接线表）

---

# chatgpt response

可以。这里说的“确认总线”，指的是先确认 **I2C 总线**。你这套车载传感器里，先要挂到 I2C 总线上的主要是这三个模块：

```text
1. LCD1602 I2C 液晶屏
2. PCF8591 AD/DA 模块
3. MPU6050 / GY-521 加速度陀螺仪模块
```

文档里也提到 LCD、AD/DA、加速度传感器相关配置和接线注意事项，并说明 LCD 常见地址是 `0x27`，加速度传感器建议接 3.3V。

## I2C 总线接线原则

这三个模块不是一个一个占不同 GPIO，而是**并联接在同一组 SDA / SCL 上**：

```text
SDA 全部接 GPIO2 / SDA
SCL 全部接 GPIO3 / SCL
GND 全部共地
VCC 按模块要求接 3.3V 或 5V
```

你的 T 型板是 BCM 编号，所以直接看板子上标的：

```text
SDA / GPIO2
SCL / GPIO3
```

---

## 接线表一：LCD1602 I2C

你的 LCD 后面是 4 针接口，标的是：

```text
GND  VCC  SDA  SCL
```

按这个接：

| LCD1602 I2C | 树莓派 T 型板 |
|---|---|
| GND | GND |
| VCC | 5V |
| SDA | SDA / GPIO2 |
| SCL | SCL / GPIO3 |

LCD 先按教程接 5V。后面如果屏幕不显示，先不要怀疑代码，先调 LCD 背面的蓝色电位器，文档里也提到 LCD 不显示可能需要调背光/对比度。

---

## 接线表二：PCF8591 AD/DA 模块

你这个 PCF8591 板子下面有一排：

```text
SDA  SCL  VCC  GND
```

按这个接：

| PCF8591 | 树莓派 T 型板 |
|---|---|
| SDA | SDA / GPIO2 |
| SCL | SCL / GPIO3 |
| VCC | 3.3V |
| GND | GND |

后面光敏传感器的模拟输出 `AO` 再接到 PCF8591 的 `AIN1`，但现在只是确认 I2C 总线，可以先不接光敏。

---

## 接线表三：MPU6050 / GY-521

你这个 GY-521 模块右边引脚是：

```text
VCC
GND
SCL
SDA
XDA
XCL
ADO
INT
```

确认 I2C 总线时，只需要接前四个：

| MPU6050 / GY-521 | 树莓派 T 型板 |
|---|---|
| VCC | 3.3V |
| GND | GND |
| SDA | SDA / GPIO2 |
| SCL | SCL / GPIO3 |

`XDA / XCL / ADO / INT` 先全部不接。

---

## 三个模块合起来的总接线表

| 树莓派 T 型板 | 接到哪里 |
|---|---|
| GPIO2 / SDA | LCD 的 SDA、PCF8591 的 SDA、MPU6050 的 SDA |
| GPIO3 / SCL | LCD 的 SCL、PCF8591 的 SCL、MPU6050 的 SCL |
| GND | LCD 的 GND、PCF8591 的 GND、MPU6050 的 GND |
| 5V | LCD 的 VCC |
| 3.3V | PCF8591 的 VCC、MPU6050 的 VCC |

也就是：

```text
GPIO2/SDA  →  三个模块的 SDA
GPIO3/SCL  →  三个模块的 SCL
GND        →  三个模块的 GND
5V         →  LCD VCC
3.3V       →  PCF8591 VCC、MPU6050 VCC
```

---

## 接好以后检查

接完以后，在树莓派终端输入：

```bash
i2cdetect -y 1
```

正常情况下，你应该能看到类似这些地址：

| 地址 | 对应模块 |
|---|---|
| `27` 或 `3f` | LCD1602 |
| `48` | PCF8591 |
| `68` | MPU6050 |

也就是说，结果里面最好能看到：

```text
27   48   68
```

或者：

```text
3f   48   68
```

你接好之后，把 `i2cdetect -y 1` 的结果截图/复制给我。下一步我们就根据实际扫出来的地址，先测 LCD。

---

# you asked

message time: 2026-06-01 05:26:06

我的是AO VCC DO GND

---

# chatgpt response

你这个 **AO / VCC / DO / GND** 不是 I2C 总线模块，它应该是**光敏传感器模块**或者**雨滴传感器控制板**这类“模拟/数字输出模块”。

它和 LCD、MPU6050、PCF8591 不一样：

```text
AO  = 模拟输出
DO  = 数字输出
VCC = 电源
GND = 地
```

所以它**不能接 SDA/SCL**，也不会出现在 `i2cdetect -y 1` 里面。

## 如果你说的是光敏传感器

自动大灯建议用 **AO**，接到 PCF8591 的模拟输入。

接线表如下：

| 光敏模块 | 接到哪里 |
|---|---|
| AO | PCF8591 的 AIN1 |
| VCC | 3.3V |
| DO | 暂时不接 |
| GND | GND |

然后 PCF8591 自己再接树莓派 I2C：

| PCF8591 | 树莓派 T 型板 |
|---|---|
| SDA | GPIO2 / SDA |
| SCL | GPIO3 / SCL |
| VCC | 3.3V |
| GND | GND |

也就是说，光敏模块不是直接接树莓派 GPIO，而是：

```text
光敏 AO → PCF8591 AIN1 → I2C → 树莓派
```

这样后面程序能读到亮度数值，比如 0 到 255。

---

## 如果你说的是雨滴传感器控制板

雨滴传感器最终建议用 **DO**，简单稳定。

接线表如下：

| 雨滴控制板 | 树莓派 T 型板 |
|---|---|
| AO | 暂时不接 |
| VCC | 3.3V |
| DO | GPIO22 |
| GND | GND |

雨滴板本体那两根针，接到控制板另一侧的两针接口。

这样后面程序直接判断：

```text
DO 电平变化 → 有雨 / 无雨
```

---

## 所以现在总线确认只包括这 3 个

真正需要接到 I2C 总线的是：

```text
1. LCD1602 I2C
2. PCF8591 AD/DA
3. MPU6050 / GY-521
```

它们才接：

```text
SDA → GPIO2
SCL → GPIO3
```

而 **AO/VCC/DO/GND 这种模块不接 SDA/SCL**。

文档里车辆传感器部分需要光敏、雨滴、超声波、编码器、加速度等模块；常见问题也提到多个模拟传感器接 AD 模块时，应接 AIN0、AIN1、AIN2、AIN3 这类输入口。

你现在先确认一句：你说的这个 **AO / VCC / DO / GND** 是光敏模块，还是雨滴控制板？两个接法不一样。

---

# you asked

message time: 2026-06-01 05:31:04

这个是哪个啊，我看教程上这个就是PcF，那LeD是哪个啊

---

# chatgpt response

对，这张图这个就是 **PCF8591 AD/DA 模块**，教程里的那个 **PCF** 就是它。

它的作用不是 LED，而是：**把光敏、电位器、热敏这些模拟量转换成树莓派能读的数字值**。

## 这个模块怎么看

你手上这个板子上面有：

```text id="kxqpt8"
GND
VCC
SCL
SDA
```

这一排就是接树莓派 I2C 的。

接线表：

| PCF8591 | 树莓派 T 型板 |
|---|---|
| GND | GND |
| VCC | 3.3V |
| SCL | GPIO3 / SCL |
| SDA | GPIO2 / SDA |

你现在接的方向看起来是对的。

---

## PCF8591 板上的这个小圆片是什么？

你图左下角那个像“蛇形纹路”的小圆片，是**光敏电阻**。

也就是说，这块 PCF8591 板子本身就带了光敏传感器，可以直接用来做“自动大灯”的亮度检测。

文档里也提到 AD 模块上集成了多个模拟输入，光敏电阻对应 `AIN1 / INPUT1`，程序里一般读 `PCF + 1`。

所以自动大灯可以这样做：

```text id="3apvdf"
PCF8591 板载光敏电阻 → 检测环境亮度
GPIO 控制外部 LED → 模拟车灯开关
```

---

## 那 LED 是哪个？

LED 不是 PCF8591 这块板。

你前面发的这个红灯模块才是 LED：

```text id="3ehih0"
S / + / -
```

也就是这个：

| LED 模块 | 树莓派 T 型板 |
|---|---|
| S | GPIO17 |
| + | 3.3V |
| - | GND |

它用来当“自动大灯”。

---

## 简单区分一下

| 模块 | 作用 |
|---|---|
| PCF8591 | 读取光敏模拟值 |
| PCF8591 板上的光敏电阻 | 检测亮暗 |
| 红色 LED 模块 | 作为车灯 |
| 雨滴 AO/VCC/DO/GND 模块 | 检测下雨 |
| LCD1602 | 显示状态 |

所以自动大灯这一项的完整逻辑是：

```text id="myqqn8"
PCF8591 读取光敏值
↓
判断环境亮还是暗
↓
控制红色 LED 模块亮灭
```

你现在先不用管那个单独的 `AO / VCC / DO / GND` 光敏模块了，**直接用 PCF8591 板载光敏就可以**，更符合教程。

---

# you asked

message time: 2026-06-01 05:34:40

布线问题我还没接LCD，其他的接了

---

# chatgpt response

对，你这个结果是正常的：

```text
48  → PCF8591 AD/DA 模块
68  → MPU6050 / GY-521 姿态传感器
```

因为你还没接 LCD，所以现在看不到 `27` 或 `3f` 很正常。文档里 LCD 常见地址是 `0x27`，如果例程里写的是 `0x3F` 可能要改。

## 现在 I2C 总线已经确认了两个模块

| 地址 | 模块 | 状态 |
|---|---|---|
| `0x48` | PCF8591 | 已识别 |
| `0x68` | MPU6050 | 已识别 |
| `0x27` / `0x3f` | LCD1602 | 还没接，所以没显示 |

说明你现在 **SDA / SCL 总线基本没问题**。

---

## 现在把 LCD 接上

你的 LCD 背面接口是：

```text
GND  VCC  SDA  SCL
```

按这个接：

| LCD1602 I2C | 树莓派 T 型板 |
|---|---|
| GND | GND |
| VCC | 5V |
| SDA | GPIO2 / SDA |
| SCL | GPIO3 / SCL |

也就是说，LCD 的 `SDA` 和 PCF8591、MPU6050 的 `SDA` 接在同一个 GPIO2；LCD 的 `SCL` 和它们的 `SCL` 接在同一个 GPIO3。

```text
GPIO2 / SDA → LCD SDA + PCF8591 SDA + MPU6050 SDA
GPIO3 / SCL → LCD SCL + PCF8591 SCL + MPU6050 SCL
GND         → 三个模块 GND 全部共地
```

---

## 接完后重新运行

```bash
i2cdetect -y 1
```

理想结果应该变成类似：

```text
27  48  68
```

或者：

```text
3f  48  68
```

如果 LCD 接上后还是只看到：

```text
48  68
```

那就重点检查：

```text
1. LCD 的 VCC/GND 有没有接反
2. SDA 有没有接 GPIO2
3. SCL 有没有接 GPIO3
4. LCD 背面蓝色电位器是否需要拧一下
5. 杜邦线有没有松
```

你现在先接 LCD，然后把新的 `i2cdetect -y 1` 结果发我。看到 LCD 地址以后，我们再开始测 LCD 显示。

---

# you asked

message time: 2026-06-01 05:35:36

肯定是27，不用试了，开始做项目吧

---

# you asked

message time: 2026-06-01 05:36:33

肯定是27，不用试了，开始做项目吧

---

# chatgpt response

可以，那就直接开始做**最终版工程**。先按文档车辆传感器五项来：自动大灯、自动雨刷、障碍物报警、行驶里程计量、姿态感知，并用 C + makefile 组织。文档里也要求多个传感器组合，并专门讲了 makefile 写法。

先把接线固定成这一版。

## 最终接线表，BCM 编号

### 1. I2C 总线

| 模块 | 模块引脚 | 树莓派 T 型板 |
|---|---|---|
| LCD1602 | GND | GND |
| LCD1602 | VCC | 5V |
| LCD1602 | SDA | GPIO2 / SDA |
| LCD1602 | SCL | GPIO3 / SCL |
| PCF8591 | GND | GND |
| PCF8591 | VCC | 3.3V |
| PCF8591 | SDA | GPIO2 / SDA |
| PCF8591 | SCL | GPIO3 / SCL |
| MPU6050 | GND | GND |
| MPU6050 | VCC | 3.3V |
| MPU6050 | SDA | GPIO2 / SDA |
| MPU6050 | SCL | GPIO3 / SCL |

你现在已经扫到：

```text
0x48 → PCF8591
0x68 → MPU6050
```

LCD 先按：

```text
0x27
```

### 2. 车辆传感器功能接线

| 功能 | 模块 | 模块引脚 | 树莓派 T 型板 |
|---|---|---|---|
| 自动大灯 | 红色 LED 模块 | S | GPIO17 |
| 自动大灯 | 红色 LED 模块 | + | 3.3V |
| 自动大灯 | 红色 LED 模块 | - | GND |
| 自动雨刷 | 雨滴控制板 | DO | GPIO22 |
| 自动雨刷 | 雨滴控制板 | VCC | 3.3V |
| 自动雨刷 | 雨滴控制板 | GND | GND |
| 障碍物报警 | HC-SR04 | Trig | GPIO23 |
| 障碍物报警 | HC-SR04 | Echo | GPIO24 |
| 障碍物报警 | HC-SR04 | VCC | 5V |
| 障碍物报警 | HC-SR04 | GND | GND |
| 蜂鸣器报警 | 蜂鸣器 | I/O | GPIO27 |
| 蜂鸣器报警 | 蜂鸣器 | VCC | 3.3V，若不响再接 5V |
| 蜂鸣器报警 | 蜂鸣器 | GND | GND |
| 行驶里程 | 旋转编码器 | CLK | GPIO5 |
| 行驶里程 | 旋转编码器 | DT | GPIO6 |
| 行驶里程 | 旋转编码器 | SW | GPIO13，可选 |
| 行驶里程 | 旋转编码器 | + | 3.3V |
| 行驶里程 | 旋转编码器 | GND | GND |

PCF8591 板载光敏要注意：如果板上有跳线帽，确保 **AIN1 和 INPUT1** 是短接状态，因为文档里说明光敏电阻对应 AIN1/INPUT1，程序读取 `PCF+1`。

---

# 创建最终工程

在树莓派终端执行：

```bash
mkdir -p ~/automatic_car
cd ~/automatic_car
```

下面这些文件按顺序创建。

---

## 1. config.h

```bash
cat > config.h <<'EOF'
#ifndef CONFIG_H
#define CONFIG_H

// =====================
// BCM GPIO pin mapping
// =====================
#define LED_PIN                 17
#define RAIN_DO_PIN             22
#define BUZZER_PIN              27

#define ULTRASONIC_TRIG_PIN     23
#define ULTRASONIC_ECHO_PIN     24

#define ENCODER_A_PIN           5
#define ENCODER_B_PIN           6
#define ENCODER_SW_PIN          13

// =====================
// I2C addresses
// =====================
#define LCD_ADDR                0x27
#define PCF8591_ADDR            0x48
#define MPU6050_ADDR            0x68

// PCF8591 onboard photoresistor channel
// According to the guide: photoresistor is AIN1 / INPUT1.
#define LIGHT_CHANNEL           1

// =====================
// Active level settings
// Change these if your module works opposite.
// =====================
#define LED_ACTIVE_HIGH         1
#define BUZZER_ACTIVE_HIGH      1
#define RAIN_ACTIVE_LOW         1

// Some PCF8591 boards return higher value when darker,
// some return lower value when darker.
// If LED behavior is reversed, change this to 0.
#define LIGHT_DARK_WHEN_HIGH    1

// =====================
// Thresholds
// Tune after testing.
// =====================
#define LIGHT_DARK_THRESHOLD    120

#define DIST_WARN_CM            30.0f
#define DIST_DANGER_CM          10.0f

#define TILT_THRESHOLD_DEG      35.0f

// Encoder mileage coefficient.
// For MVP/final demo, count is already acceptable.
// You can tune this later according to wheel size.
#define MILEAGE_PER_COUNT_CM    1.0f

#define DISPLAY_PAGE_MS         2000
#define BUZZER_SLOW_PERIOD_MS   800
#define BUZZER_FAST_PERIOD_MS   200

#endif
EOF
```

---

## 2. lcd1602.h / lcd1602.c

```bash
cat > lcd1602.h <<'EOF'
#ifndef LCD1602_H
#define LCD1602_H

int lcd_init(int addr);
void lcd_clear(void);
void lcd_write_line(int row, const char *text);
void lcd_backlight(int on);

#endif
EOF

cat > lcd1602.c <<'EOF'
#include "lcd1602.h"
#include <stdio.h>
#include <string.h>
#include <wiringPi.h>
#include <wiringPiI2C.h>

#define LCD_CHR 1
#define LCD_CMD 0

#define LCD_LINE1 0x80
#define LCD_LINE2 0xC0

#define LCD_BACKLIGHT 0x08
#define LCD_NOBACKLIGHT 0x00

#define ENABLE 0x04

static int lcd_fd = -1;
static int lcd_light = LCD_BACKLIGHT;

static void lcd_toggle_enable(int bits)
{
    delayMicroseconds(500);
    wiringPiI2CWrite(lcd_fd, bits | ENABLE | lcd_light);
    delayMicroseconds(500);
    wiringPiI2CWrite(lcd_fd, (bits & ~ENABLE) | lcd_light);
    delayMicroseconds(100);
}

static void lcd_write4bits(int bits)
{
    wiringPiI2CWrite(lcd_fd, bits | lcd_light);
    lcd_toggle_enable(bits);
}

static void lcd_send(int value, int mode)
{
    int high = mode | (value & 0xF0);
    int low  = mode | ((value << 4) & 0xF0);

    lcd_write4bits(high);
    lcd_write4bits(low);
}

int lcd_init(int addr)
{
    lcd_fd = wiringPiI2CSetup(addr);
    if (lcd_fd < 0)
    {
        printf("LCD init failed at address 0x%02X\n", addr);
        return -1;
    }

    delay(50);

    lcd_write4bits(0x30);
    delay(5);
    lcd_write4bits(0x30);
    delayMicroseconds(150);
    lcd_write4bits(0x30);
    lcd_write4bits(0x20);

    lcd_send(0x28, LCD_CMD); // 4-bit, 2 line, 5x8 dots
    lcd_send(0x0C, LCD_CMD); // display on, cursor off
    lcd_send(0x06, LCD_CMD); // entry mode
    lcd_clear();

    return 0;
}

void lcd_clear(void)
{
    lcd_send(0x01, LCD_CMD);
    delay(2);
}

void lcd_write_line(int row, const char *text)
{
    char buf[17];
    int i;

    memset(buf, ' ', 16);
    buf[16] = '\0';

    if (text != NULL)
    {
        for (i = 0; i < 16 && text[i] != '\0'; i++)
        {
            buf[i] = text[i];
        }
    }

    lcd_send(row == 0 ? LCD_LINE1 : LCD_LINE2, LCD_CMD);

    for (i = 0; i < 16; i++)
    {
        lcd_send(buf[i], LCD_CHR);
    }
}

void lcd_backlight(int on)
{
    lcd_light = on ? LCD_BACKLIGHT : LCD_NOBACKLIGHT;
    wiringPiI2CWrite(lcd_fd, lcd_light);
}
EOF
```

---

## 3. pcf8591.h / pcf8591.c

```bash
cat > pcf8591.h <<'EOF'
#ifndef PCF8591_H
#define PCF8591_H

int pcf8591_init(int addr);
int pcf8591_read(int fd, int channel);

#endif
EOF

cat > pcf8591.c <<'EOF'
#include "pcf8591.h"
#include <stdio.h>
#include <wiringPiI2C.h>

int pcf8591_init(int addr)
{
    int fd = wiringPiI2CSetup(addr);
    if (fd < 0)
    {
        printf("PCF8591 init failed at address 0x%02X\n", addr);
    }
    return fd;
}

int pcf8591_read(int fd, int channel)
{
    int control = 0x40 | (channel & 0x03);

    wiringPiI2CWrite(fd, control);

    // First read is dummy read for PCF8591.
    wiringPiI2CRead(fd);

    return wiringPiI2CRead(fd) & 0xFF;
}
EOF
```

---

## 4. led.h / led.c

```bash
cat > led.h <<'EOF'
#ifndef LED_H
#define LED_H

void led_init(void);
void led_set(int on);

#endif
EOF

cat > led.c <<'EOF'
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
    int level;

    if (LED_ACTIVE_HIGH)
    {
        level = on ? HIGH : LOW;
    }
    else
    {
        level = on ? LOW : HIGH;
    }

    digitalWrite(LED_PIN, level);
}
EOF
```

---

## 5. light.h / light.c

```bash
cat > light.h <<'EOF'
#ifndef LIGHT_H
#define LIGHT_H

int light_read_value(int pcf_fd);
int light_is_dark(int value);

#endif
EOF

cat > light.c <<'EOF'
#include "light.h"
#include "config.h"
#include "pcf8591.h"

int light_read_value(int pcf_fd)
{
    return pcf8591_read(pcf_fd, LIGHT_CHANNEL);
}

int light_is_dark(int value)
{
    if (LIGHT_DARK_WHEN_HIGH)
    {
        return value >= LIGHT_DARK_THRESHOLD;
    }
    else
    {
        return value <= LIGHT_DARK_THRESHOLD;
    }
}
EOF
```

---

## 6. rain.h / rain.c

```bash
cat > rain.h <<'EOF'
#ifndef RAIN_H
#define RAIN_H

void rain_init(void);
int rain_is_wet(void);
int rain_raw_value(void);

#endif
EOF

cat > rain.c <<'EOF'
#include "rain.h"
#include "config.h"
#include <wiringPi.h>

void rain_init(void)
{
    pinMode(RAIN_DO_PIN, INPUT);
    pullUpDnControl(RAIN_DO_PIN, PUD_UP);
}

int rain_raw_value(void)
{
    return digitalRead(RAIN_DO_PIN);
}

int rain_is_wet(void)
{
    int raw = rain_raw_value();

    if (RAIN_ACTIVE_LOW)
    {
        return raw == LOW;
    }
    else
    {
        return raw == HIGH;
    }
}
EOF
```

---

## 7. buzzer.h / buzzer.c

```bash
cat > buzzer.h <<'EOF'
#ifndef BUZZER_H
#define BUZZER_H

void buzzer_init(void);
void buzzer_off(void);
void buzzer_task(int level);

#endif
EOF

cat > buzzer.c <<'EOF'
#include "buzzer.h"
#include "config.h"
#include <wiringPi.h>

static int buzzer_state = 0;
static unsigned int last_toggle_ms = 0;

static void buzzer_write(int on)
{
    int level;

    if (BUZZER_ACTIVE_HIGH)
    {
        level = on ? HIGH : LOW;
    }
    else
    {
        level = on ? LOW : HIGH;
    }

    digitalWrite(BUZZER_PIN, level);
}

void buzzer_init(void)
{
    pinMode(BUZZER_PIN, OUTPUT);
    buzzer_off();
}

void buzzer_off(void)
{
    buzzer_state = 0;
    buzzer_write(0);
}

void buzzer_task(int level)
{
    unsigned int now;
    unsigned int half_period;

    if (level <= 0)
    {
        buzzer_off();
        return;
    }

    half_period = (level >= 2 ? BUZZER_FAST_PERIOD_MS : BUZZER_SLOW_PERIOD_MS) / 2;
    now = millis();

    if (now - last_toggle_ms >= half_period)
    {
        last_toggle_ms = now;
        buzzer_state = !buzzer_state;
        buzzer_write(buzzer_state);
    }
}
EOF
```

---

## 8. ultrasonic.h / ultrasonic.c

```bash
cat > ultrasonic.h <<'EOF'
#ifndef ULTRASONIC_H
#define ULTRASONIC_H

void ultrasonic_init(void);
float ultrasonic_read_cm(void);

#endif
EOF

cat > ultrasonic.c <<'EOF'
#include "ultrasonic.h"
#include "config.h"
#include <wiringPi.h>

#define ULTRA_TIMEOUT_US 30000

void ultrasonic_init(void)
{
    pinMode(ULTRASONIC_TRIG_PIN, OUTPUT);
    pinMode(ULTRASONIC_ECHO_PIN, INPUT);
    digitalWrite(ULTRASONIC_TRIG_PIN, LOW);
    delay(50);
}

float ultrasonic_read_cm(void)
{
    unsigned int wait_start;
    unsigned int pulse_start;
    unsigned int pulse_end;
    unsigned int duration;

    digitalWrite(ULTRASONIC_TRIG_PIN, LOW);
    delayMicroseconds(2);

    digitalWrite(ULTRASONIC_TRIG_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(ULTRASONIC_TRIG_PIN, LOW);

    wait_start = micros();
    while (digitalRead(ULTRASONIC_ECHO_PIN) == LOW)
    {
        if (micros() - wait_start > ULTRA_TIMEOUT_US)
        {
            return -1.0f;
        }
    }

    pulse_start = micros();
    while (digitalRead(ULTRASONIC_ECHO_PIN) == HIGH)
    {
        if (micros() - pulse_start > ULTRA_TIMEOUT_US)
        {
            return -1.0f;
        }
    }

    pulse_end = micros();
    duration = pulse_end - pulse_start;

    return duration * 0.0343f / 2.0f;
}
EOF
```

---

## 9. encoder.h / encoder.c

```bash
cat > encoder.h <<'EOF'
#ifndef ENCODER_H
#define ENCODER_H

int encoder_init(void);
long encoder_get_count(void);
void encoder_reset(void);

#endif
EOF

cat > encoder.c <<'EOF'
#include "encoder.h"
#include "config.h"
#include <stdio.h>
#include <wiringPi.h>

static volatile long encoder_count = 0;
static volatile int last_encoded = 0;

static void encoder_update(void)
{
    int msb = digitalRead(ENCODER_A_PIN);
    int lsb = digitalRead(ENCODER_B_PIN);
    int encoded = (msb << 1) | lsb;
    int sum = (last_encoded << 2) | encoded;

    if (sum == 0b1101 || sum == 0b0100 || sum == 0b0010 || sum == 0b1011)
    {
        encoder_count++;
    }

    if (sum == 0b1110 || sum == 0b0111 || sum == 0b0001 || sum == 0b1000)
    {
        encoder_count--;
    }

    last_encoded = encoded;
}

int encoder_init(void)
{
    pinMode(ENCODER_A_PIN, INPUT);
    pinMode(ENCODER_B_PIN, INPUT);
    pinMode(ENCODER_SW_PIN, INPUT);

    pullUpDnControl(ENCODER_A_PIN, PUD_UP);
    pullUpDnControl(ENCODER_B_PIN, PUD_UP);
    pullUpDnControl(ENCODER_SW_PIN, PUD_UP);

    last_encoded = (digitalRead(ENCODER_A_PIN) << 1) | digitalRead(ENCODER_B_PIN);

    if (wiringPiISR(ENCODER_A_PIN, INT_EDGE_BOTH, &encoder_update) < 0)
    {
        printf("Failed to setup encoder A interrupt.\n");
        return -1;
    }

    if (wiringPiISR(ENCODER_B_PIN, INT_EDGE_BOTH, &encoder_update) < 0)
    {
        printf("Failed to setup encoder B interrupt.\n");
        return -1;
    }

    return 0;
}

long encoder_get_count(void)
{
    return encoder_count;
}

void encoder_reset(void)
{
    encoder_count = 0;
}
EOF
```

---

## 10. mpu6050.h / mpu6050.c

```bash
cat > mpu6050.h <<'EOF'
#ifndef MPU6050_H
#define MPU6050_H

int mpu6050_init(int addr);
int mpu6050_read_angles(int fd, float *roll, float *pitch);
int mpu6050_is_tilted(float roll, float pitch);

#endif
EOF

cat > mpu6050.c <<'EOF'
#include "mpu6050.h"
#include "config.h"
#include <stdio.h>
#include <math.h>
#include <wiringPiI2C.h>
#include <wiringPi.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define MPU6050_REG_PWR_MGMT_1 0x6B
#define MPU6050_REG_ACCEL_XOUT_H 0x3B

static int read_word_2c(int fd, int reg)
{
    int high = wiringPiI2CReadReg8(fd, reg);
    int low = wiringPiI2CReadReg8(fd, reg + 1);
    int value = (high << 8) + low;

    if (value >= 0x8000)
    {
        value = -((65535 - value) + 1);
    }

    return value;
}

int mpu6050_init(int addr)
{
    int fd = wiringPiI2CSetup(addr);
    if (fd < 0)
    {
        printf("MPU6050 init failed at address 0x%02X\n", addr);
        return -1;
    }

    wiringPiI2CWriteReg8(fd, MPU6050_REG_PWR_MGMT_1, 0x00);
    delay(100);

    return fd;
}

int mpu6050_read_angles(int fd, float *roll, float *pitch)
{
    int ax_raw;
    int ay_raw;
    int az_raw;

    float ax;
    float ay;
    float az;

    if (fd < 0 || roll == NULL || pitch == NULL)
    {
        return -1;
    }

    ax_raw = read_word_2c(fd, MPU6050_REG_ACCEL_XOUT_H);
    ay_raw = read_word_2c(fd, MPU6050_REG_ACCEL_XOUT_H + 2);
    az_raw = read_word_2c(fd, MPU6050_REG_ACCEL_XOUT_H + 4);

    ax = ax_raw / 16384.0f;
    ay = ay_raw / 16384.0f;
    az = az_raw / 16384.0f;

    *roll = atan2f(ay, az) * 180.0f / (float)M_PI;
    *pitch = atan2f(-ax, sqrtf(ay * ay + az * az)) * 180.0f / (float)M_PI;

    return 0;
}

int mpu6050_is_tilted(float roll, float pitch)
{
    return fabsf(roll) >= TILT_THRESHOLD_DEG || fabsf(pitch) >= TILT_THRESHOLD_DEG;
}
EOF
```

---

## 11. display.h / display.c

```bash
cat > display.h <<'EOF'
#ifndef DISPLAY_H
#define DISPLAY_H

typedef struct
{
    int light_value;
    int light_on;
    int raining;

    float distance_cm;
    int alarm_level;

    long encoder_count;
    float mileage_cm;

    float roll;
    float pitch;
    int tilted;
} AppState;

void display_update(const AppState *state);

#endif
EOF

cat > display.c <<'EOF'
#include "display.h"
#include "config.h"
#include "lcd1602.h"
#include <stdio.h>
#include <wiringPi.h>

void display_update(const AppState *s)
{
    static unsigned int last_page_ms = 0;
    static unsigned int last_refresh_ms = 0;
    static int page = 0;

    unsigned int now = millis();

    char line1[17];
    char line2[17];

    if (s == NULL)
    {
        return;
    }

    if (now - last_refresh_ms < 400)
    {
        return;
    }
    last_refresh_ms = now;

    if (now - last_page_ms >= DISPLAY_PAGE_MS)
    {
        last_page_ms = now;
        page = (page + 1) % 3;
    }

    if (s->distance_cm > 0 && s->distance_cm <= DIST_DANGER_CM)
    {
        lcd_write_line(0, "WARNING!");
        lcd_write_line(1, "Obstacle Near");
        return;
    }

    if (s->tilted)
    {
        lcd_write_line(0, "WARNING!");
        lcd_write_line(1, "Car Tilted");
        return;
    }

    switch (page)
    {
        case 0:
            snprintf(line1, sizeof(line1), "Light:%s L:%03d", s->light_on ? "ON " : "OFF", s->light_value);
            snprintf(line2, sizeof(line2), "Rain :%s", s->raining ? "YES" : "NO ");
            break;

        case 1:
            if (s->distance_cm < 0)
            {
                snprintf(line1, sizeof(line1), "Dist: ---- cm");
            }
            else
            {
                snprintf(line1, sizeof(line1), "Dist:%6.1fcm", s->distance_cm);
            }

            if (s->alarm_level >= 2)
            {
                snprintf(line2, sizeof(line2), "Buzzer:FAST");
            }
            else if (s->alarm_level == 1)
            {
                snprintf(line2, sizeof(line2), "Buzzer:SLOW");
            }
            else
            {
                snprintf(line2, sizeof(line2), "Buzzer:OFF");
            }
            break;

        default:
            snprintf(line1, sizeof(line1), "Mile:%7.1fcm", s->mileage_cm);
            snprintf(line2, sizeof(line2), "Pose:%s", s->tilted ? "Tilt" : "Normal");
            break;
    }

    lcd_write_line(0, line1);
    lcd_write_line(1, line2);
}
EOF
```

---

## 12. main.c

```bash
cat > main.c <<'EOF'
#include <stdio.h>
#include <signal.h>
#include <wiringPi.h>

#include "config.h"
#include "lcd1602.h"
#include "pcf8591.h"
#include "led.h"
#include "light.h"
#include "rain.h"
#include "buzzer.h"
#include "ultrasonic.h"
#include "encoder.h"
#include "mpu6050.h"
#include "display.h"

static volatile int running = 1;

static void handle_sigint(int sig)
{
    (void)sig;
    running = 0;
}

int main(void)
{
    int pcf_fd;
    int mpu_fd;

    float distance_cm = -1.0f;
    unsigned int last_distance_ms = 0;

    AppState state;

    signal(SIGINT, handle_sigint);

    if (wiringPiSetupGpio() == -1)
    {
        printf("wiringPiSetupGpio failed.\n");
        return 1;
    }

    printf("Automatic Car Sensor System Start...\n");
    printf("Pin mode: BCM GPIO.\n");

    led_init();
    rain_init();
    buzzer_init();
    ultrasonic_init();

    if (encoder_init() < 0)
    {
        printf("Encoder init warning. Continue running.\n");
    }

    if (lcd_init(LCD_ADDR) < 0)
    {
        printf("LCD init warning. Check LCD address and wiring.\n");
    }
    else
    {
        lcd_write_line(0, "Automatic Car");
        lcd_write_line(1, "System Start");
        delay(1000);
        lcd_clear();
    }

    pcf_fd = pcf8591_init(PCF8591_ADDR);
    if (pcf_fd < 0)
    {
        printf("PCF8591 init failed. Stop.\n");
        return 1;
    }

    mpu_fd = mpu6050_init(MPU6050_ADDR);
    if (mpu_fd < 0)
    {
        printf("MPU6050 init warning. Pose function disabled.\n");
    }

    printf("Running... Press Ctrl+C to stop.\n");

    while (running)
    {
        unsigned int now = millis();

        state.light_value = light_read_value(pcf_fd);
        state.light_on = light_is_dark(state.light_value);
        led_set(state.light_on);

        state.raining = rain_is_wet();

        if (now - last_distance_ms >= 300)
        {
            last_distance_ms = now;
            distance_cm = ultrasonic_read_cm();
        }

        state.distance_cm = distance_cm;

        state.encoder_count = encoder_get_count();
        state.mileage_cm = state.encoder_count * MILEAGE_PER_COUNT_CM;

        state.roll = 0.0f;
        state.pitch = 0.0f;
        state.tilted = 0;

        if (mpu_fd >= 0)
        {
            if (mpu6050_read_angles(mpu_fd, &state.roll, &state.pitch) == 0)
            {
                state.tilted = mpu6050_is_tilted(state.roll, state.pitch);
            }
        }

        state.alarm_level = 0;

        if (state.distance_cm > 0 && state.distance_cm <= DIST_WARN_CM)
        {
            state.alarm_level = 1;
        }

        if (state.distance_cm > 0 && state.distance_cm <= DIST_DANGER_CM)
        {
            state.alarm_level = 2;
        }

        if (state.tilted)
        {
            state.alarm_level = 2;
        }

        buzzer_task(state.alarm_level);
        display_update(&state);

        printf("\rLight=%3d LED=%s Rain=%s Dist=%6.1fcm Count=%ld Mile=%.1fcm Roll=%6.1f Pitch=%6.1f Alarm=%d     ",
               state.light_value,
               state.light_on ? "ON " : "OFF",
               state.raining ? "YES" : "NO ",
               state.distance_cm,
               state.encoder_count,
               state.mileage_cm,
               state.roll,
               state.pitch,
               state.alarm_level);
        fflush(stdout);

        delay(100);
    }

    printf("\nStopping system...\n");

    buzzer_off();
    led_set(0);
    lcd_clear();
    lcd_write_line(0, "System Stopped");

    return 0;
}
EOF
```

---

## 13. makefile

```bash
cat > makefile <<'EOF'
.RECIPEPREFIX := >

CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2
LDLIBS = -lwiringPi -lm -lpthread

TARGET = automatic_car

SRCS = main.c \
       lcd1602.c \
       pcf8591.c \
       led.c \
       light.c \
       rain.c \
       buzzer.c \
       ultrasonic.c \
       encoder.c \
       mpu6050.c \
       display.c

OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
>$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

%.o: %.c
>$(CC) $(CFLAGS) -c $< -o $@

clean:
>rm -f $(OBJS) $(TARGET)

rebuild: clean all
EOF
```

---

# 编译运行

```bash
make
./automatic_car
```

正常情况下，终端会实时显示：

```text
Light=xxx LED=ON/OFF Rain=YES/NO Dist=xx.xcm Count=xxx Mile=xxx Roll=xxx Pitch=xxx Alarm=x
```

LCD 会轮播显示：

```text
Light / Rain
Dist / Buzzer
Mileage / Pose
```

---

# 运行后最可能需要调的地方

打开：

```bash
nano config.h
```

### 1. LED 反了

现象：应该亮时不亮，应该灭时亮。

改：

```c
#define LED_ACTIVE_HIGH 0
```

然后：

```bash
make clean
make
./automatic_car
```

### 2. 蜂鸣器反了

现象：不该响时一直响。

改：

```c
#define BUZZER_ACTIVE_HIGH 0
```

### 3. 雨滴状态反了

现象：没水显示 YES，有水显示 NO。

改：

```c
#define RAIN_ACTIVE_LOW 0
```

### 4. 光敏方向反了

现象：亮处 LED 亮，暗处 LED 灭。

改：

```c
#define LIGHT_DARK_WHEN_HIGH 0
```

### 5. 光敏阈值不合适

终端里看 `Light=xxx`。

用手遮住 PCF8591 板载光敏，看数值变化，然后调：

```c
#define LIGHT_DARK_THRESHOLD 120
```

例如亮处是 50，暗处是 180，那阈值可以设 120。

---

你现在先完整接线、编译运行。第一轮跑起来后，把终端里这一行数据发我，尤其是：

```text
Light=xxx
Rain=YES/NO
Dist=xx.x
Roll=xxx
Pitch=xxx
```

然后我们根据真实数据调阈值和反向参数。

---

# you asked

message time: 2026-06-01 05:43:39

不用这样写，我要先在自己的电脑里写，然后再发送上去

---

# chatgpt response

明白，你的意思是：**代码文件先在 Windows 电脑本地建好，用 VS Code / 记事本编辑，然后再传到树莓派编译运行**。这样更合理，也更方便改。

后面我们就不用 `cat > xxx.c <<EOF` 这种树莓派终端里直接写文件的方式了。

## 推荐工作流

你在 Windows 本地建一个文件夹，比如：

```text
automatic_car
```

里面放这些文件：

```text
automatic_car/
├── main.c
├── config.h
├── lcd1602.c
├── lcd1602.h
├── pcf8591.c
├── pcf8591.h
├── led.c
├── led.h
├── light.c
├── light.h
├── rain.c
├── rain.h
├── buzzer.c
├── buzzer.h
├── ultrasonic.c
├── ultrasonic.h
├── encoder.c
├── encoder.h
├── mpu6050.c
├── mpu6050.h
├── display.c
├── display.h
└── makefile
```

你在本地只负责写代码；**不要在 Windows 上编译**，因为这个项目依赖树莓派上的 `wiringPi` 和 GPIO 硬件。

---

## 本地写完后怎么传到树莓派

### 方法一：FileZilla，最适合你现在

连接信息：

```text
协议：SFTP
主机：192.168.137.10
端口：22
用户名：pi
密码：raspberry
```

然后把 Windows 里的 `automatic_car` 文件夹拖到树莓派：

```text
/home/pi/
```

最后树莓派终端里：

```bash
cd ~/automatic_car
make
./automatic_car
```

---

### 方法二：PowerShell 用 scp

如果你 Windows 可以用 `ssh`，也可以在项目文件夹的上一级打开 PowerShell：

```powershell
scp -r .\automatic_car pi@192.168.137.10:/home/pi/
```

然后到树莓派：

```bash
cd ~/automatic_car
make
./automatic_car
```

---

## 特别注意 makefile

`makefile` 这个文件在 Windows 里写的时候，有两个坑：

第一，文件名就叫：

```text
makefile
```

不要叫：

```text
makefile.txt
```

第二，传统 makefile 的命令行前面必须是 **Tab**，不是空格。比如：

```makefile
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)
```

第二行前面那个空白必须是 Tab。

为了避免你在 Windows 复制时 Tab 出问题，我后面给你的 makefile 可以用这种写法：

```makefile
.RECIPEPREFIX := >
```

这样命令前面用 `>`，不用 Tab，更适合复制粘贴。

---

## 接下来我们这样做

我不会一次性把所有文件都堆给你。我们按本地项目方式来：

```text
第一步：先创建项目结构和 config.h
第二步：写 LED、蜂鸣器、雨滴这些简单模块
第三步：写 I2C：LCD、PCF8591、MPU6050
第四步：写超声波、编码器
第五步：写 main.c 和 makefile
第六步：上传到树莓派编译调试
```

这样你每一步都能知道每个文件是干嘛的，不会变成一坨代码。

下一步我先给你 **最终版 config.h**，它是整个项目的“接线表 + 参数表”。你本地先建 `automatic_car/config.h`。

---

# you asked

message time: 2026-06-08 03:39:36

怎么接线

---

# chatgpt response

可以，下面就按你现在的**树莓派 4B + BCM 编码 T 型板**来接。代码后面全部用 `wiringPiSetupGpio()`，所以表里的 `GPIO17` 就是 T 型板上写的 `G17/GPIO17`。

文档里车辆传感器要做自动大灯、雨滴检测、超声波报警、编码器里程、姿态感知；常见问题里也提醒了 AD/DA、蜂鸣器、光敏等多用 3.3V，超声波和 LCD 多用 5V，加速度传感器建议 3.3V。

## 总接线表

### 一、I2C 总线：LCD + PCF8591 + MPU6050

这三个模块都接同一组 SDA/SCL，不是分别占不同 GPIO。

| 模块 | 模块引脚 | 接树莓派 T 型板 |
|---|---|---|
| LCD1602 | GND | GND |
| LCD1602 | VCC | 5V |
| LCD1602 | SDA | GPIO2 / SDA |
| LCD1602 | SCL | GPIO3 / SCL |
| PCF8591 | GND | GND |
| PCF8591 | VCC | 3.3V |
| PCF8591 | SDA | GPIO2 / SDA |
| PCF8591 | SCL | GPIO3 / SCL |
| MPU6050 / GY-521 | VCC | 3.3V |
| MPU6050 / GY-521 | GND | GND |
| MPU6050 / GY-521 | SDA | GPIO2 / SDA |
| MPU6050 / GY-521 | SCL | GPIO3 / SCL |

也就是：

```text
GPIO2/SDA → LCD SDA + PCF8591 SDA + MPU6050 SDA
GPIO3/SCL → LCD SCL + PCF8591 SCL + MPU6050 SCL
GND       → 三个模块都接 GND
```

你之前已经扫到 `0x48` 和 `0x68`，说明 PCF8591 和 MPU6050 没问题。LCD 地址按你说的用 `0x27`。

---

### 二、自动大灯：PCF8591 板载光敏 + 红色 LED

PCF8591 板子上那个小光敏电阻直接用来检测亮暗，不需要再接单独光敏模块。

LED 用你拍的那个红色 LED 模块：

| LED 模块 | 接树莓派 T 型板 |
|---|---|
| S | GPIO17 |
| + | 3.3V |
| - | GND |

自动大灯逻辑：

```text
PCF8591 读取板载光敏值
环境暗 → GPIO17 控制 LED 亮
环境亮 → LED 灭
```

注意：PCF8591 板子上如果有跳线帽，确认光敏对应的 `AIN1 / INPUT1` 是连上的。文档里说明光敏电阻对应 AD 模块的 AIN1/INPUT1，程序里读 `PCF+1`。

---

### 三、自动雨刷：雨滴板 + 雨滴控制板

你这个雨滴控制板是：

```text
AO / VCC / DO / GND
```

我们先用 `DO` 数字输出，简单稳定。

| 雨滴控制板 | 接树莓派 T 型板 |
|---|---|
| AO | 不接 |
| VCC | 3.3V |
| DO | GPIO22 |
| GND | GND |

雨滴板本体那块大板：

| 雨滴板 | 接到哪里 |
|---|---|
| 两个针脚 | 接雨滴控制板另一侧的 2 针接口 |

---

### 四、障碍物报警：HC-SR04 + 蜂鸣器

你说按教程直接接，那就先按教程直连。

#### HC-SR04 超声波

| HC-SR04 | 接树莓派 T 型板 |
|---|---|
| VCC | 5V |
| Trig | GPIO23 |
| Echo | GPIO24 |
| GND | GND |

#### 蜂鸣器模块

你的蜂鸣器是：

```text
I/O / VCC / GND
```

接法：

| 蜂鸣器 | 接树莓派 T 型板 |
|---|---|
| I/O | GPIO27 |
| VCC | 3.3V，若不响再试 5V |
| GND | GND |

障碍物报警逻辑：

```text
超声波测距离
距离小于 30cm → 蜂鸣器慢响
距离小于 10cm → 蜂鸣器快响
```

---

### 五、行驶里程：旋转编码器

你那个编码器引脚是：

```text
GND / + / SW / DT / CLK
```

接法：

| 旋转编码器 | 接树莓派 T 型板 |
|---|---|
| GND | GND |
| + | 3.3V |
| SW | GPIO13，可选 |
| DT | GPIO6 |
| CLK | GPIO5 |

`SW` 是按下旋钮的按钮，里程计数主要用 `CLK` 和 `DT`。

---

## 最终完整接线汇总

| 功能 | 模块引脚 | 树莓派 BCM |
|---|---|---|
| LED 大灯 | S | GPIO17 |
| 雨滴检测 | DO | GPIO22 |
| 超声波 Trig | Trig | GPIO23 |
| 超声波 Echo | Echo | GPIO24 |
| 蜂鸣器 | I/O | GPIO27 |
| 编码器 CLK | CLK | GPIO5 |
| 编码器 DT | DT | GPIO6 |
| 编码器 SW | SW | GPIO13 |
| I2C SDA | LCD/PCF/MPU SDA | GPIO2 |
| I2C SCL | LCD/PCF/MPU SCL | GPIO3 |

电源汇总：

| 模块 | VCC |
|---|---|
| LCD1602 | 5V |
| HC-SR04 | 5V |
| PCF8591 | 3.3V |
| MPU6050 | 3.3V |
| 雨滴控制板 | 3.3V |
| LED 模块 | 3.3V |
| 蜂鸣器 | 3.3V，不响再 5V |
| 旋转编码器 | 3.3V |

## 接完先检查

接完以后先跑：

```bash
i2cdetect -y 1
```

你应该看到：

```text
27  48  68
```

分别是：

```text
27 → LCD1602
48 → PCF8591
68 → MPU6050
```

确认这三个地址都在之后，再开始上传代码编译。

---

# you asked

message time: 2026-06-08 04:02:26

雨滴检测是哪个模块

---

# chatgpt response

雨滴检测模块一般是**两部分**：

```text
1. 雨滴感应板：大一点的板子，表面有很多平行/网格状金属线
2. 雨滴控制板：小板子，上面有 AO / VCC / DO / GND，还有一个蓝色电位器
```

你之前说的这个：

```text
AO / VCC / DO / GND
```

就是**雨滴传感器的控制板**。

接线时这样接：

| 雨滴控制板 | 接树莓派 T 型板 |
|---|---|
| AO | 暂时不接 |
| VCC | 3.3V |
| DO | GPIO22 |
| GND | GND |

然后那块**雨滴感应板**用两根线接到控制板另一边的 2 针接口上。

简单说：

```text
雨滴板 → 接雨滴控制板
雨滴控制板 DO → GPIO22
雨滴控制板 VCC → 3.3V
雨滴控制板 GND → GND
```

`AO` 是模拟输出，需要接 PCF8591 才能读数；我们最终版先用 `DO`，因为文档 MVP 只需要判断“有没有雨”，检测到雨水后 LCD 显示 `Raining` 就够了。

---

# chatgpt response

这个就是**雨滴感应板本体**，也就是检测有没有水滴的那块板。

它**不是直接接树莓派 GPIO 的**，它要接到你那个小蓝板控制模块上，也就是你说的：

```text
AO  VCC  DO  GND
```

那块小蓝板才负责把雨滴板的变化转换成 `AO/DO` 信号。

## 雨滴检测完整接线

### 1. 雨滴感应板 → 雨滴控制板

你手上这块 `MH-RD Raindrops module` 有两个针脚。

| 雨滴感应板 | 接到哪里 |
|---|---|
| 两个针脚 | 接雨滴控制板另一侧的 2 针接口 |

这两个针脚本质上就是检测板两端，通常**不分正负**。如果控制板那边标了 `+ / -`，就按标识接；没标也没关系。

---

### 2. 雨滴控制板 → 树莓派

你那个小蓝板是：

```text
AO  VCC  DO  GND
```

接线表如下：

| 雨滴控制板 | 树莓派 T 型板 |
|---|---|
| AO | 暂时不接 |
| VCC | 3.3V |
| DO | GPIO22 |
| GND | GND |

所以完整链路是：

```text
雨滴感应板
   ↓ 两根线
雨滴控制板
   ↓ DO
GPIO22
```

文档车辆传感器里“自动雨刷”要求的是检测有雨水后在 LCD 显示 `Raining`，所以我们先用 `DO` 数字输出就够了，简单稳定。

## 注意小蓝板上的蓝色旋钮

雨滴控制板上有一个蓝色电位器，用来调灵敏度。

后面测试时：

```text
干燥状态 → DO 一种电平
滴水/手摸湿 → DO 变成另一种电平
```

如果没反应，就慢慢拧那个蓝色旋钮，直到板上的 `DO-LED` 会随着干湿变化亮灭。

## 当前最终接法确认

雨滴检测这一项就定成：

```text
雨滴板两针 → 雨滴控制板两针
雨滴控制板 VCC → 3.3V
雨滴控制板 GND → GND
雨滴控制板 DO  → GPIO22
雨滴控制板 AO  → 不接
```

后面代码里就用 `GPIO22` 判断：

```text
有雨 → LCD 显示 Raining
无雨 → LCD 显示 No Rain
```

---

# you asked

message time: 2026-06-08 04:08:19

这些代码写的对吗

---

# chatgpt response

整体结构**可以作为 `config.h` 的雏形**，但按你现在的硬件和接线方案，里面有几处要改，不然代码和实际接线会对不上。你这个文件现在写的是 wiringPi 编号，而且光敏/雨滴/编码器定义也和我们刚确认的方案不完全一致。

最大问题是这一句：

```c
/* wiringPi pin numbers. Change these to match your wiring. */
```

你前面已经确认 **T 型板是 BCM 编码**，所以我们后面应该用：

```c
wiringPiSetupGpio();
```

因此 `config.h` 里也应该全部写 **BCM GPIO 编号**，不是 wiringPi 编号。

你现在这个：

```c
#define LED_PIN 0
#define BUZZER_PIN 2
#define RAIN_DIGITAL_PIN 3
#define ULTRASONIC_TRIG_PIN 4
#define ULTRASONIC_ECHO_PIN 5
```

如果配合 `wiringPiSetupGpio()`，就会变成 GPIO0、GPIO2、GPIO3……这不是我们定的接线。应该改成：

```c
#define LED_PIN                 17
#define BUZZER_PIN              27
#define RAIN_DIGITAL_PIN        22
#define ULTRASONIC_TRIG_PIN     23
#define ULTRASONIC_ECHO_PIN     24
```

第二个问题是编码器。你写的是：

```c
#define ENCODER_LEFT_PIN        21
#define ENCODER_RIGHT_PIN       22
```

但你手上是一个旋转编码器模块，引脚是：

```text
GND / + / SW / DT / CLK
```

所以建议改成：

```c
#define ENCODER_CLK_PIN         5
#define ENCODER_DT_PIN          6
#define ENCODER_SW_PIN          13
```

第三个问题是 PCF8591 通道。你现在写：

```c
#define LIGHT_ADC_CHANNEL       0
#define RAIN_ADC_CHANNEL        1
```

但我们打算用 **PCF8591 板载光敏**做自动大灯，按教程/文档说明，光敏一般对应 `AIN1 / INPUT1`，所以光敏更建议写：

```c
#define LIGHT_ADC_CHANNEL       1
```

雨滴检测我们现在用的是 `DO → GPIO22`，所以暂时不需要：

```c
#define RAIN_ADC_CHANNEL
#define RAIN_WET_THRESHOLD
```

除非你后面改成雨滴 `AO → PCF8591 AINx`。

可以先把你的 `config.h` 改成这个版本：

```c
#ifndef CONFIG_H
#define CONFIG_H

#include <stdint.h>

/*
 * Pin mode:
 * Use wiringPiSetupGpio().
 * All GPIO numbers below are BCM numbers, matching the BCM T-board labels.
 */

// GPIO output/input pins
#define LED_PIN                 17
#define BUZZER_PIN              27
#define RAIN_DIGITAL_PIN        22

#define ULTRASONIC_TRIG_PIN     23
#define ULTRASONIC_ECHO_PIN     24

// Rotary encoder pins
#define ENCODER_CLK_PIN         5
#define ENCODER_DT_PIN          6
#define ENCODER_SW_PIN          13

// I2C device addresses
#define LCD1602_I2C_ADDR        0x27
#define PCF8591_I2C_ADDR        0x48
#define MPU6050_I2C_ADDR        0x68

// PCF8591 analog channel
// On the teaching module, onboard photoresistor usually maps to AIN1.
#define LIGHT_ADC_CHANNEL       1

// Thresholds, tune after real testing
#define LIGHT_DARK_THRESHOLD    120
#define OBSTACLE_DISTANCE_CM    20.0f
#define TILT_THRESHOLD_DEG      35.0f

#define LOOP_DELAY_MS           300

// Encoder / mileage
#define ENCODER_PULSES_PER_REV  20
#define WHEEL_DIAMETER_CM       6.5f

typedef struct {
    int light_value;
    int light_on;

    int rain_raw;
    int rain_detected;

    float distance_cm;
    int obstacle_detected;

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

这样就和我们目前定的接线一致：

```text
LED        → GPIO17
雨滴 DO    → GPIO22
超声波 Trig → GPIO23
超声波 Echo → GPIO24
蜂鸣器      → GPIO27
编码器 CLK  → GPIO5
编码器 DT   → GPIO6
编码器 SW   → GPIO13
LCD        → 0x27
PCF8591    → 0x48
MPU6050    → 0x68
```

还有一点：后面所有 `.c` 文件里初始化 GPIO 时必须用：

```c
wiringPiSetupGpio();
```

不要用：

```c
wiringPiSetup();
```

否则这些 BCM 编号会全部错位。

---

# you asked

message time: 2026-06-08 04:09:54

你写一份根据引脚和接线的程序设计代码文档，我交给vs code的agent实现

---

# chatgpt response

下面这份可以直接复制给 VS Code Agent。它是**项目实现说明/代码生成文档**，重点固定了：BCM 引脚、模块接线、工程结构、每个文件职责、核心函数接口和验收方式。

依据你上传的指导书：车辆传感器要实现自动大灯、自动雨刷、障碍物报警、行驶里程计量、姿态感知；指导书也建议用 makefile 组织多个 C 文件，并提醒 LCD 地址为 `0x27`、PCF8591 光敏通常对应 AIN1/INPUT1、I2C/电压/`WiringPiSetup()` 等注意事项。   你之前上传的 `config.h` 里写的是 wiringPi 编号，需要按下面文档改成 BCM 编号。

**Document Title: **

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

| 模块 | 模块引脚 | Raspberry Pi 4B / BCM T 型板 |
|---|---|---|
| LCD1602 I2C | GND | GND |
| LCD1602 I2C | VCC | 5V |
| LCD1602 I2C | SDA | GPIO2 / SDA |
| LCD1602 I2C | SCL | GPIO3 / SCL |
| PCF8591 AD/DA | GND | GND |
| PCF8591 AD/DA | VCC | 3.3V |
| PCF8591 AD/DA | SDA | GPIO2 / SDA |
| PCF8591 AD/DA | SCL | GPIO3 / SCL |
| MPU6050 / GY-521 | VCC | 3.3V |
| MPU6050 / GY-521 | GND | GND |
| MPU6050 / GY-521 | SDA | GPIO2 / SDA |
| MPU6050 / GY-521 | SCL | GPIO3 / SCL |

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
|---|---|
| S | GPIO17 |
| + | 3.3V |
| - | GND |

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
|---|---|
| AO | 暂时不接 |
| VCC | 3.3V |
| DO | GPIO22 |
| GND | GND |

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
|---|---|
| VCC | 5V |
| Trig | GPIO23 |
| Echo | GPIO24 |
| GND | GND |

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

| 蜂鸣器 | Raspberry Pi |
|---|---|
| I/O | GPIO27 |
| VCC | 3.3V，若不响可试 5V |
| GND | GND |

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
|---|---|
| GND | GND |
| + | 3.3V |
| SW | GPIO13 |
| DT | GPIO6 |
| CLK | GPIO5 |

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

- `led_init()` 设置 `LED_PIN` 为输出。
- `led_set(1)` 点亮 LED。
- `led_set(0)` 熄灭 LED。
- 必须考虑 `LED_ACTIVE_HIGH` 宏。

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

- `alarm_level = 0`：不响。
- `alarm_level = 1`：慢速间歇响。
- `alarm_level = 2`：快速间歇响。
- 必须使用非阻塞方式，不要在 `buzzer_task()` 中长时间 `delay()`。
- 使用 `millis()` 控制定时。
- 必须考虑 `BUZZER_ACTIVE_HIGH` 宏。

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

- `RAIN_DIGITAL_PIN` 设置为输入。
- 可启用上拉：`pullUpDnControl(RAIN_DIGITAL_PIN, PUD_UP);`
- 根据 `RAIN_ACTIVE_LOW` 判断是否有雨。

---

### 6.4 pcf8591.c / pcf8591.h

职责：读取 PCF8591 模拟量。

接口：

```c
int pcf8591_init(int addr);
int pcf8591_read_channel(int fd, int channel);
```

要求：

- 使用 `wiringPiI2CSetup(addr)`。
- 读取时写控制字 `0x40 | channel`。
- PCF8591 第一次读取是 dummy read，应丢弃第一次读数。
- 返回 0 到 255 的 ADC 值。

---

### 6.5 light.c / light.h

职责：自动大灯判断。

接口：

```c
int light_read_value(int pcf_fd);
int light_is_dark(int value);
```

要求：

- `light_read_value()` 读取 `LIGHT_ADC_CHANNEL`。
- `light_is_dark()` 根据 `LIGHT_DARK_WHEN_HIGH` 和 `LIGHT_DARK_THRESHOLD` 判断是否暗。
- 主程序根据 `light_is_dark()` 控制 LED。

---

### 6.6 ultrasonic.c / ultrasonic.h

职责：读取 HC-SR04 距离。

接口：

```c
void ultrasonic_init(void);
float ultrasonic_read_cm(void);
```

要求：

- Trig 为输出，Echo 为输入。
- Trig 输出 10us 高电平触发测距。
- 使用 `micros()` 测 Echo 高电平持续时间。
- 必须有超时保护，避免程序卡死。
- 超时返回 `-1.0f`。

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

- CLK、DT、SW 都设为输入，并启用上拉。
- 用 `wiringPiISR()` 对 CLK 或 CLK+DT 设置中断。
- 根据 CLK/DT 相位判断加减。
- SW 可选：按下时清零。
- 里程根据 `ENCODER_PULSES_PER_REV` 和 `WHEEL_DIAMETER_CM` 计算。

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

- 初始化时解除睡眠：写 `PWR_MGMT_1 = 0x00`。
- 原始加速度按 ±2g 默认量程换算，比例为 `16384.0f`。
- 计算 roll 和 pitch。
- `abs(roll) >= TILT_THRESHOLD_DEG` 或 `abs(pitch) >= TILT_THRESHOLD_DEG` 判断为倾斜。
- 需要 `#include <math.h>`，makefile 链接 `-lm`。

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

- LCD 地址为 `0x27`。
- 支持 16x2 显示。
- `lcd1602_write_line(row, text)` 自动补空格/截断，避免残留字符。
- row=0 表示第一行，row=1 表示第二行。

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
   - 光敏值
   - 雨滴状态
   - 超声波距离
   - 编码器 tick 和里程
   - MPU6050 姿态
9. 更新 `CarStatus`。
10. 根据状态控制：
   - LED
   - 蜂鸣器
   - LCD 显示
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

- 光敏值
- LED 状态
- 雨滴状态
- 距离
- 编码器计数
- 里程
- roll
- pitch
- alarm_level

---

## 10. 需要预留的调参宏

由于实际模块可能电平相反，必须把这些做成宏：

```c
#define LED_ACTIVE_HIGH         1
#define BUZZER_ACTIVE_HIGH      1
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

把这份发给 VS Code Agent 后，让它先生成项目骨架和 `config.h`，再逐个实现模块。你可以要求它“不要一次性压缩成单文件，必须按文档的多文件结构生成”。

---

# you asked

message time: 2026-06-08 04:26:32

OK了，我现在要上传到树莓派运行

---

# chatgpt response

好，现在流程就是：

```text
Windows 本地写代码
        ↓ 上传整个 automatic_car 文件夹
树莓派 /home/pi/automatic_car
        ↓ make 编译
        ↓ ./automatic_car 运行
```

## 方法一：用 FileZilla 上传，最稳

打开 FileZilla，填：

```text
主机：sftp://192.168.137.10
用户名：pi
密码：raspberry
端口：22
```

如果你的树莓派 IP 不是 `192.168.137.10`，就用你 SSH 登录时的那个 IP。

连接后，左边是 Windows，右边是树莓派。

把你本地的：

```text
automatic_car
```

整个文件夹拖到树莓派右边的：

```text
/home/pi/
```

上传完成后，树莓派里应该是：

```text
/home/pi/automatic_car/main.c
/home/pi/automatic_car/config.h
/home/pi/automatic_car/makefile
...
```

---

## 方法二：PowerShell 一条命令上传

在 Windows 打开 PowerShell，进入你项目文件夹的上一级。比如你的项目在：

```text
D:\automatic_car
```

那就进入 `D:\`：

```powershell
cd D:\
```

然后执行：

```powershell
scp -r .\automatic_car pi@192.168.137.10:/home/pi/
```

输入密码：

```text
raspberry
```

如果提示是否信任，输入：

```text
yes
```

---

## 树莓派上编译运行

SSH 登录树莓派：

```powershell
ssh pi@192.168.137.10
```

进入项目：

```bash
cd ~/automatic_car
```

先看一下文件在不在：

```bash
ls
```

你应该能看到：

```text
main.c
config.h
makefile
lcd1602.c
lcd1602.h
...
```

然后编译：

```bash
make
```

运行：

```bash
./automatic_car
```

停止运行：

```bash
Ctrl + C
```

---

## 如果 make 报错：Permission denied / bad interpreter / strange character

可能是 Windows 换行符问题，先装一下转换工具：

```bash
sudo apt-get update
sudo apt-get install dos2unix -y
```

然后在项目目录执行：

```bash
dos2unix *.c *.h makefile
```

再重新编译：

```bash
make clean
make
./automatic_car
```

---

## 如果提示找不到 wiringPi

先试：

```bash
gpio -v
```

如果能显示 wiringPi 版本，说明有。

如果提示没有 `gpio` 或 `wiringPi.h` 找不到，把报错发我；你这个实验镜像大概率已经装好了，因为你前面的双色 LED 已经能用 `-lwiringPi` 编译运行。

---

## 运行前最好先确认 I2C

```bash
i2cdetect -y 1
```

最好能看到：

```text
27  48  68
```

分别对应：

```text
27 → LCD1602
48 → PCF8591
68 → MPU6050
```

然后再运行项目。

你现在先上传、`make`。如果报错，把完整报错复制给我，不要只截一半。

---

# you asked

message time: 2026-06-08 04:31:14

这个算好了吗，怎么板级测试

---

# chatgpt response

算是**程序已经跑起来了**，但还不能说“全部好了”。从你屏幕上的数据看：

```text
Light=89~102
LED=OFF
Rain=NO
Dist=209~213cm
Count=0
Roll≈-128
Pitch≈-29
Alarm=2
```

说明至少这些模块已经有数据返回：

```text
PCF8591 光敏：有数值
雨滴 DO：有状态
超声波：能测出距离
MPU6050：能读出姿态值
主循环：正常运行
```

但现在有一个明显问题：**Alarm=2 一直在报警等级 2**，大概率是因为 `Roll=-128` 超过了倾斜阈值，所以程序一直判断“车辆倾斜”。这不代表坏了，可能是 MPU6050 安装方向/角度公式导致静止时基准不是 0，需要校准。

文档要求是车辆传感器五项功能都能演示：自动大灯、自动雨刷、障碍物报警、里程计量、姿态感知。你现在进入的是“板级测试”阶段，就是逐个功能用手触发，看终端和硬件反应是否符合预期。

## 板级测试顺序

### 1. 先测 I2C

运行：

```bash
i2cdetect -y 1
```

确认有：

```text
27  48  68
```

分别对应：

```text
27 → LCD
48 → PCF8591
68 → MPU6050
```

如果 LCD 没显示，先确认 `27` 在不在，再调 LCD 背面的蓝色电位器。

---

### 2. 测自动大灯

看终端里的：

```text
Light=xx
LED=ON/OFF
```

用手遮住 PCF8591 板子上的光敏电阻，观察 `Light` 是否明显变化。

正常现象：

```text
遮住光敏 → Light 数值变化 → LED 应该亮
放开光敏 → Light 数值变化 → LED 应该灭
```

如果 `Light` 有变化但 LED 不亮，检查 LED 接线：

```text
LED S → GPIO17
LED + → 3.3V
LED - → GND
```

如果逻辑反了，比如亮的时候灭、暗的时候亮，就改 `config.h`：

```c
#define LIGHT_DARK_WHEN_HIGH 0
```

或者如果 LED 本身反了，改：

```c
#define LED_ACTIVE_HIGH 0
```

---

### 3. 测雨滴检测

看终端里的：

```text
Rain=NO
```

然后往雨滴板上滴一点水，或者用湿手轻轻碰雨滴板。

正常现象：

```text
干燥 → Rain=NO
有水 → Rain=YES
LCD 显示 Raining
```

如果一直是 `NO`，调雨滴控制板上的蓝色电位器，直到板上的 DO-LED 会随着干湿变化亮灭。

如果有水时显示 `NO`，没水时显示 `YES`，改：

```c
#define RAIN_ACTIVE_LOW 0
```

---

### 4. 测超声波

你现在 `Dist=209~213cm`，说明超声波已经有返回值。拿手靠近 HC-SR04 前方。

正常现象：

```text
手远离 → Dist 大
手靠近 → Dist 变小
小于 30cm → Alarm=1，蜂鸣器慢响
小于 10cm → Alarm=2，蜂鸣器快响
```

你屏幕里出现过：

```text
Dist=8.2cm
Alarm=2
```

这个说明超声波报警逻辑大概率能触发。

不过你现在 `Alarm=2` 可能被 MPU6050 倾斜报警占用了，所以测超声波时最好先临时把姿态报警阈值调大，比如：

```c
#define TILT_THRESHOLD_DEG 180.0f
```

这样可以先排除 MPU6050 对蜂鸣器的影响。

---

### 5. 测编码器

看终端：

```text
Count=0
Mile=0.0cm
```

转动旋转编码器。

正常现象：

```text
顺时针转 → Count 增加
逆时针转 → Count 减少
Mile 随 Count 变化
```

如果怎么转都是 0，重点检查：

```text
编码器 +   → 3.3V
编码器 GND → GND
编码器 CLK → GPIO5
编码器 DT  → GPIO6
编码器 SW  → GPIO13，可选
```

如果数值反向，不是大问题，后面可以交换 CLK/DT 或在代码里把加减反过来。

---

### 6. 测 MPU6050 姿态

你现在：

```text
Roll≈-128
Pitch≈-29
Alarm=2
```

这个说明 MPU6050 有数据，但静止基准不太理想。你可以拿起 MPU6050 轻轻改变角度，看 `Roll` 和 `Pitch` 是否跟着变化。

正常现象：

```text
倾斜模块 → Roll/Pitch 明显变化
恢复水平 → Roll/Pitch 回到某个稳定值附近
```

如果它稳定在 `Roll=-128` 附近，也可以接受，但代码不能直接用“是否大于 35 度”判断，应该改成**相对初始姿态判断**。

也就是程序启动时记录初始值：

```text
base_roll = 当前 Roll
base_pitch = 当前 Pitch
```

之后判断：

```text
abs(roll - base_roll) > 35
或者
abs(pitch - base_pitch) > 35
```

这样你静止时不会一直报警，真正被拿起来倾斜时才报警。

---

## 你现在这个状态怎么判断？

现在结论是：

```text
程序能运行；
I2C/超声波/雨滴/光敏/MPU6050 基本都有数据；
但还没完成板级验收；
当前最大问题是 MPU6050 让 Alarm=2 一直触发。
```

下一步建议你先改两个地方：

```c
#define TILT_THRESHOLD_DEG 180.0f
```

先临时关闭姿态报警影响，然后按顺序测：

```text
1. 光敏 + LED
2. 雨滴
3. 超声波 + 蜂鸣器
4. 编码器
5. 最后再单独调 MPU6050
```

这样最容易定位问题。

---

# you asked

message time: 2026-06-08 04:36:56

蜂鸣器一上电就不停响；LED始终量，光敏有数值变化

---

# chatgpt response

先别慌，这两个现象都很典型：

```text
蜂鸣器一运行/一上电就响：
大概率是 ① 蜂鸣器高低电平触发写反了，或者 ② 你的程序一直 Alarm=2。

LED 始终亮：
大概率是 LED 模块是“低电平点亮”，但代码按“高电平点亮”写了。
```

你截图里之前有一行很关键：

```text
Dist=209cm 但是 Alarm=2
Roll=-128 Pitch=-29
```

距离明明很远还 `Alarm=2`，说明蜂鸣器不停响很可能不是超声波触发，而是 **MPU6050 姿态判断一直触发报警**。另外，你上传的 `config.h` 一开始还是 wiringPi 编号风格，后面必须改成 BCM 编号并用 `wiringPiSetupGpio()`。

## 第一步：先用命令判断 LED/蜂鸣器到底是高电平还是低电平触发

先停止程序：

```bash
Ctrl + C
```

然后在树莓派终端执行。

### 测 LED，GPIO17

```bash
gpio -g mode 17 out
gpio -g write 17 1
```

看 LED 是否亮。

再执行：

```bash
gpio -g write 17 0
```

看 LED 是否亮。

结论：

```text
write 17 1 亮，write 17 0 灭 → LED_ACTIVE_HIGH = 1
write 17 0 亮，write 17 1 灭 → LED_ACTIVE_HIGH = 0
```

你这个红色 LED 模块很可能是第二种，也就是**低电平点亮**。

---

### 测蜂鸣器，GPIO27

```bash
gpio -g mode 27 out
gpio -g write 27 1
```

听蜂鸣器是否响。

再执行：

```bash
gpio -g write 27 0
```

听蜂鸣器是否响。

结论：

```text
write 27 1 响，write 27 0 不响 → BUZZER_ACTIVE_HIGH = 1
write 27 0 响，write 27 1 不响 → BUZZER_ACTIVE_HIGH = 0
```

很多 `I/O / VCC / GND` 的蜂鸣器模块也是**低电平触发**，所以很可能要设成：

```c
#define BUZZER_ACTIVE_HIGH 0
```

---

## 第二步：先临时关掉 MPU6050 姿态报警

因为你现在 `Roll=-128`，程序会一直认为车倾斜，所以蜂鸣器一直报警。

先打开 `config.h`，把姿态报警阈值临时改大：

```c
#define TILT_THRESHOLD_DEG 180.0f
```

这样先让 MPU6050 不参与报警，方便你单独测超声波和蜂鸣器。

后面我们再把姿态判断改成“相对初始角度”，不是直接用绝对 Roll/Pitch 判断。

---

## 第三步：按测试结果改 config.h

大概率你现在需要先这样改：

```c
#define LED_ACTIVE_HIGH         0
#define BUZZER_ACTIVE_HIGH      0
#define RAIN_ACTIVE_LOW         1
#define LIGHT_DARK_WHEN_HIGH    1

#define TILT_THRESHOLD_DEG      180.0f
```

然后重新编译运行：

```bash
make clean
make
./automatic_car
```

---

## 第四步：判断 LED 是阈值问题还是电平问题

运行后看终端：

```text
Light=xxx LED=ON/OFF
```

如果终端显示：

```text
LED=OFF
```

但实际 LED 还是亮，那就是 **LED_ACTIVE_HIGH 写反了**。

如果终端一直显示：

```text
LED=ON
```

那就是光敏阈值/方向问题。用手遮住 PCF8591 上的光敏，看 `Light` 数值怎么变：

```text
遮住后 Light 变大 → LIGHT_DARK_WHEN_HIGH = 1
遮住后 Light 变小 → LIGHT_DARK_WHEN_HIGH = 0
```

然后把阈值调到亮暗之间，比如：

```text
亮的时候 Light≈90
遮住后 Light≈180
```

就设：

```c
#define LIGHT_DARK_THRESHOLD 130
```

---

## 现在最优先改这两个

先做这两个改动：

```c
#define LED_ACTIVE_HIGH         0
#define BUZZER_ACTIVE_HIGH      0
#define TILT_THRESHOLD_DEG      180.0f
```

然后重新 `make clean && make` 运行。这样应该能解决：

```text
蜂鸣器一直响
LED 始终亮但终端显示 OFF
```

跑完后你把新的终端输出发我，重点看这几个：

```text
Light=?
LED=ON/OFF
Dist=?
Roll=?
Pitch=?
Alarm=?
```

---

# you asked

message time: 2026-06-08 04:39:23

蜂鸣器是低电平触发；LED一直亮，是不是接错了

---

# chatgpt response

有可能接错，但也可能只是 **LED 模块触发电平和代码相反**。先用最简单的方法判断。

## 先确认 LED 模块三根线

你的 LED 模块应该是：

```text
S   +   -
```

正确接法应该是：

| LED 模块 | 树莓派 |
|---|---|
| S | GPIO17 |
| + | 3.3V |
| - | GND |

千万不要接成：

```text
S 接 3.3V
+ 接 GPIO17
- 接 GND
```

如果这样接，LED 很可能一直亮。

---

## 做一个不用代码的判断

先停止程序：

```bash
Ctrl + C
```

然后只保留 LED 的：

```text
+ → 3.3V
- → GND
```

把 `S` 那根线拔掉。

### 结果 1：S 拔掉后 LED 还亮

那说明接法或模块理解有问题。这个 LED 可能不是按 `S/+/-` 控制的，或者你把 `+/-` 接成了常亮回路。你需要重新拍一下 LED 模块背面和插线位置。

### 结果 2：S 拔掉后 LED 灭

那接线大概率没错，只是 `S` 这个信号脚的高低电平控制问题。

---

## 再用 GPIO 命令测试 GPIO17

接回：

```text
S → GPIO17
+ → 3.3V
- → GND
```

然后执行：

```bash
gpio -g mode 17 out
gpio -g write 17 1
```

看 LED 是否亮。

再执行：

```bash
gpio -g write 17 0
```

看 LED 是否亮。

判断：

```text
write 17 1 亮，write 17 0 灭
→ LED 是高电平触发
→ config.h 里 LED_ACTIVE_HIGH = 1

write 17 0 亮，write 17 1 灭
→ LED 是低电平触发
→ config.h 里 LED_ACTIVE_HIGH = 0
```

---

## 你现在 config.h 应该先这样改

既然你已经确认蜂鸣器是低电平触发：

```c
#define BUZZER_ACTIVE_HIGH 0
```

LED 需要用上面的 GPIO 命令测出来。如果你没测，LED 一直亮时可以先试：

```c
#define LED_ACTIVE_HIGH 0
```

然后重新编译：

```bash
make clean
make
./automatic_car
```

---

## 还有一个重要点

如果程序终端显示：

```text
LED=OFF
```

但实际 LED 亮，那就是 **LED_ACTIVE_HIGH 写反了**。

如果程序终端显示：

```text
LED=ON
```

且实际 LED 也亮，那不是接线问题，而是**光敏判断阈值/方向问题**，要调：

```c
#define LIGHT_DARK_WHEN_HIGH
#define LIGHT_DARK_THRESHOLD
```

你现在先做这个测试：**拔掉 LED 的 S 线，只留 + 和 -，看它还亮不亮。** 这个能最快判断是不是接错。

---

# you asked

message time: 2026-06-08 04:40:12

蜂鸣器怎么改

---

# chatgpt response

蜂鸣器你已经确认是**低电平触发**，所以要把代码里的蜂鸣器有效电平改成低电平。

## 1. 先改 `config.h`

找到这一行：

```c
#define BUZZER_ACTIVE_HIGH 1
```

改成：

```c
#define BUZZER_ACTIVE_HIGH 0
```

意思是：

```text
GPIO27 输出 LOW  → 蜂鸣器响
GPIO27 输出 HIGH → 蜂鸣器不响
```

---

## 2. 确认 `buzzer.c` 里面这样写

你的 `buzzer_set()` 或类似函数应该是这种逻辑：

```c
void buzzer_set(int on)
{
    if (BUZZER_ACTIVE_HIGH)
    {
        digitalWrite(BUZZER_PIN, on ? HIGH : LOW);
    }
    else
    {
        digitalWrite(BUZZER_PIN, on ? LOW : HIGH);
    }
}
```

如果你的 `buzzer.c` 里面没有这个判断，而是直接写了：

```c
digitalWrite(BUZZER_PIN, HIGH);
```

或者：

```c
digitalWrite(BUZZER_PIN, LOW);
```

那就要改成上面这种带 `BUZZER_ACTIVE_HIGH` 的写法。

---

## 3. 初始化时一定要默认关闭蜂鸣器

`buzzer_init()` 里应该这样：

```c
void buzzer_init(void)
{
    pinMode(BUZZER_PIN, OUTPUT);
    buzzer_set(0);
}
```

因为低电平触发时，关闭蜂鸣器就是让 GPIO27 输出高电平。

---

## 4. 改完重新编译

在树莓派项目目录：

```bash
cd ~/automatic_car
make clean
make
./automatic_car
```

---

## 5. 如果还是一运行就响

那很可能不是电平问题，而是程序一直处于报警状态。你之前终端里有：

```text
Alarm=2
Roll=-128
Pitch=-29
```

所以 MPU6050 姿态报警可能一直触发。先临时把 `config.h` 里这个改大：

```c
#define TILT_THRESHOLD_DEG 180.0f
```

然后重新：

```bash
make clean
make
./automatic_car
```

这样先把姿态报警屏蔽掉，只测试超声波是否能控制蜂鸣器。

---

你现在最关键先改这两行：

```c
#define BUZZER_ACTIVE_HIGH 0
#define TILT_THRESHOLD_DEG 180.0f
```

然后重新编译运行。

---

# you asked

message time: 2026-06-08 04:45:33

我怎么在树莓派里改

---

# chatgpt response

在树莓派终端里直接改就行。你现在程序目录应该是：

```bash
cd ~/automatic_car
```

先进去：

```bash
cd ~/automatic_car
ls
```

确认能看到：

```text
config.h
main.c
makefile
...
```

## 方法一：用 nano 改，最简单

打开 `config.h`：

```bash
nano config.h
```

进去之后，用方向键移动，找到这两行：

```c
#define BUZZER_ACTIVE_HIGH 1
#define TILT_THRESHOLD_DEG 35.0f
```

改成：

```c
#define BUZZER_ACTIVE_HIGH 0
#define TILT_THRESHOLD_DEG 180.0f
```

然后保存：

```text
Ctrl + O
回车
Ctrl + X
```

再重新编译运行：

```bash
make clean
make
./automatic_car
```

---

## 方法二：直接用命令替换

在 `~/automatic_car` 目录下执行：

```bash
sed -i 's/#define BUZZER_ACTIVE_HIGH[[:space:]]*1/#define BUZZER_ACTIVE_HIGH      0/' config.h
```

再执行：

```bash
sed -i 's/#define TILT_THRESHOLD_DEG[[:space:]]*35.0f/#define TILT_THRESHOLD_DEG      180.0f/' config.h
```

然后确认有没有改成功：

```bash
grep -E "BUZZER_ACTIVE_HIGH|TILT_THRESHOLD_DEG" config.h
```

应该看到类似：

```c
#define BUZZER_ACTIVE_HIGH      0
#define TILT_THRESHOLD_DEG      180.0f
```

最后重新编译运行：

```bash
make clean
make
./automatic_car
```

---

## 改完后的预期

如果蜂鸣器是低电平触发，改成：

```c
#define BUZZER_ACTIVE_HIGH 0
```

后，程序启动时应该默认不响。

如果之前是 MPU6050 一直触发 `Alarm=2`，把：

```c
#define TILT_THRESHOLD_DEG 180.0f
```

临时改大后，蜂鸣器就不会因为姿态检测一直报警。接下来再单独测试超声波靠近时蜂鸣器响不响。

---

# you asked

message time: 2026-06-08 04:49:15

我用的是dual LED，遮光变颜色，这个没关系；显示屏显示buff=off蜂鸣器依旧在响

---

# chatgpt response

对，dual LED 变颜色没关系，自动大灯能体现“遮光后变化”就行。

现在重点是蜂鸣器：**LCD 显示 `Buzz=OFF` 但蜂鸣器还响**，说明程序状态变量认为它关了，但 GPIO 实际输出/接线/触发电平有问题。

先按下面排查。

## 1. 先停程序，强制关闭 GPIO27

按：

```bash
Ctrl + C
```

然后执行：

```bash
gpio -g mode 27 out
gpio -g write 27 1
```

因为你蜂鸣器是**低电平触发**，所以：

```text
GPIO27 = 1 → 应该不响
GPIO27 = 0 → 应该响
```

然后再试：

```bash
gpio -g write 27 0
```

看它是不是响。

### 判断结果

如果：

```text
write 27 1 不响
write 27 0 响
```

说明蜂鸣器接线没问题，代码没正确把 GPIO27 拉高。

如果：

```text
write 27 1 还是响
```

那优先怀疑接线：I/O 可能没接到 GPIO27，或者 VCC/GND/I/O 插反了。

---

## 2. 确认蜂鸣器接线

你的蜂鸣器是：

```text
I/O  VCC  GND
```

应该接：

| 蜂鸣器 | 树莓派 |
|---|---|
| I/O | GPIO27 |
| VCC | 3.3V 或 5V |
| GND | GND |

注意：**I/O 一定接 GPIO27**，不要接到 3.3V、5V 或 GND。

---

## 3. 确认 config.h 真的改了

在树莓派项目目录执行：

```bash
cd ~/automatic_car
grep -E "BUZZER_ACTIVE_HIGH|TILT_THRESHOLD_DEG" config.h
```

应该看到：

```c
#define BUZZER_ACTIVE_HIGH      0
#define TILT_THRESHOLD_DEG      180.0f
```

如果 `BUZZER_ACTIVE_HIGH` 还是 `1`，就改成 `0`。

---

## 4. 改完必须重新编译

你改了 `config.h` 后，必须重新编译：

```bash
make clean
make
./automatic_car
```

如果只改文件但没重新 `make clean && make`，运行的还是旧程序。

---

## 5. 检查 buzzer.c 的关闭逻辑

打开：

```bash
nano buzzer.c
```

找到蜂鸣器控制函数，应该类似这样：

```c
void buzzer_set(int on)
{
    if (BUZZER_ACTIVE_HIGH)
    {
        digitalWrite(BUZZER_PIN, on ? HIGH : LOW);
    }
    else
    {
        digitalWrite(BUZZER_PIN, on ? LOW : HIGH);
    }
}
```

然后初始化必须是：

```c
void buzzer_init(void)
{
    pinMode(BUZZER_PIN, OUTPUT);
    buzzer_set(0);
}
```

如果你的代码里 `buzzer_off()` 是直接写：

```c
digitalWrite(BUZZER_PIN, LOW);
```

那就错了。低电平触发蜂鸣器时，`LOW` 是响，关闭应该是 `HIGH`。

低电平触发时最直接的安全写法是：

```c
void buzzer_off(void)
{
    digitalWrite(BUZZER_PIN, HIGH);
}
```

---

## 6. 先给你一个最小修改版

如果你不想看太多，直接把 `buzzer.c` 里的关闭函数改成这样：

```c
void buzzer_off(void)
{
    digitalWrite(BUZZER_PIN, HIGH);
}
```

然后 `buzzer_init()` 改成：

```c
void buzzer_init(void)
{
    pinMode(BUZZER_PIN, OUTPUT);
    digitalWrite(BUZZER_PIN, HIGH);
}
```

然后重新：

```bash
make clean
make
./automatic_car
```

---

现在先做第一步测试：

```bash
gpio -g mode 27 out
gpio -g write 27 1
gpio -g write 27 0
```

把结果告诉我：`27=1` 时响不响，`27=0` 时响不响。这样能马上判断是代码问题还是接线问题。

---

# you asked

message time: 2026-06-08 05:24:26

SW连的是哪个引脚

---

# chatgpt response

`SW` 是**旋转编码器按下去的按钮脚**，不是转动计数必须用的脚。

我们前面定的接法是：

| 旋转编码器引脚 | 接树莓派 BCM T 型板 |
|---|---|
| `CLK` | `GPIO5` |
| `DT` | `GPIO6` |
| `SW` | `GPIO13` |
| `+` | `3.3V` |
| `GND` | `GND` |

所以：

```text
SW → GPIO13
```

代码里对应：

```c
#define ENCODER_SW_PIN 13
```

如果你的程序暂时没有用“按下编码器清零里程”这个功能，`SW` 可以先不接；只接 `CLK`、`DT`、`+`、`GND` 也能完成旋转计数。

---

# you asked

message time: 2026-06-08 06:14:39

我的light输出怎么一直是255，是不是因为我输啦什么命令

---

# chatgpt response

不太像是你输错某个普通命令导致的。你前面测蜂鸣器用的：

```bash
gpio -g write 27 1
gpio -g write 27 0
```

只影响 **GPIO27**，不会影响 PCF8591 光敏读取。

`Light=255` 一直不变，通常是下面几种原因。

## 最可能原因 1：读错 PCF8591 通道

你现在可能在读：

```c
#define LIGHT_ADC_CHANNEL 1
```

但你的 PCF8591 板载光敏不一定是 AIN1，有些板子可能接在 AIN0、AIN1、AIN2 其中一个。

你可以先把 `config.h` 里改成试试：

```c
#define LIGHT_ADC_CHANNEL 0
```

重新编译运行：

```bash
make clean
make
./automatic_car
```

如果还是 255，再试：

```c
#define LIGHT_ADC_CHANNEL 1
```

再试：

```c
#define LIGHT_ADC_CHANNEL 2
```

再试：

```c
#define LIGHT_ADC_CHANNEL 3
```

哪个通道遮光时数值会明显变化，哪个就是光敏通道。

---

## 最可能原因 2：PCF8591 板上的跳线帽没插对

你那块 PCF8591 模块上一般有几个跳线帽，把板载传感器接到 AIN 通道。

如果光敏对应的跳线帽没插，程序读到的通道可能是悬空的，悬空时很容易一直读到：

```text
255
```

你检查一下 PCF8591 板子上有没有类似：

```text
AIN0 / INPUT0
AIN1 / INPUT1
AIN2 / INPUT2
```

或者几个黄色/黑色跳线帽。

教程里一般是：

```text
可调电阻 → AIN0
光敏电阻 → AIN1
热敏电阻 → AIN2
```

所以光敏那一路的跳线帽要插上。

---

## 原因 3：I2C 正常，但 ADC 读取函数写错

你先确认 PCF8591 还在线：

```bash
i2cdetect -y 1
```

应该还能看到：

```text
48
```

如果 `48` 还在，说明 I2C 没坏。

但如果代码里的 PCF8591 读取函数没有做 dummy read，也可能读数异常。正确逻辑应该类似：

```c
wiringPiI2CWrite(fd, 0x40 | channel);
wiringPiI2CRead(fd);          // dummy read
value = wiringPiI2CRead(fd);  // real value
```

如果你的 Agent 写的 `pcf8591.c` 不是这样，让它改。

---

## 原因 4：你误操作了 GPIO2/GPIO3

这个可能性比较低。只有你输入过类似：

```bash
gpio -g mode 2 out
gpio -g mode 3 out
gpio -g write 2 0
gpio -g write 3 0
```

才可能影响 I2C 总线。

如果只是操作了 `17`、`22`、`27`，不会影响光敏。

如果你怀疑动过 GPIO2/GPIO3，直接重启树莓派最省事：

```bash
sudo reboot
```

重启后再运行：

```bash
i2cdetect -y 1
```

看 `48` 是否还在。

---

## 你现在先做这三步

第一步：

```bash
i2cdetect -y 1
```

确认有没有 `48`。

第二步：检查 PCF8591 板子上光敏那一路跳线帽有没有插。

第三步：把 `LIGHT_ADC_CHANNEL` 从 `1` 改成 `0/1/2/3` 逐个试，遮住光敏看哪个通道数值会变。

只要遮光时 `Light` 从比如 `80` 变到 `180`，那通道就找对了。

---

# you asked

message time: 2026-06-08 06:16:50

是代码问题吗

---

# chatgpt response

有可能是代码问题，但**不一定**。`Light` 一直是 `255`，最常见就三类：

1. **读错 PCF8591 通道**
2. **PCF8591 读取函数写错**
3. **PCF8591 板载光敏那路跳线/硬件没接上，通道悬空**

你可以按下面判断。

## 先判断是不是代码问题

### 1. 先确认 `pcf8591.c` 读取函数

你的 PCF8591 读取函数必须类似这样：

```c
int pcf8591_read_channel(int fd, int channel)
{
    int control = 0x40 | (channel & 0x03);

    wiringPiI2CWrite(fd, control);

    wiringPiI2CRead(fd);          // dummy read，必须有
    return wiringPiI2CRead(fd) & 0xFF;
}
```

如果你的代码是这样：

```c
wiringPiI2CReadReg8(fd, channel);
```

或者没有 `dummy read`，那就可能是代码问题。

---

### 2. 让程序一次打印 AIN0~AIN3

不要只看 `LIGHT_ADC_CHANNEL`。你可以让 Agent 临时在主循环里打印：

```c
printf("AIN0=%d AIN1=%d AIN2=%d AIN3=%d\n",
       pcf8591_read_channel(pcf_fd, 0),
       pcf8591_read_channel(pcf_fd, 1),
       pcf8591_read_channel(pcf_fd, 2),
       pcf8591_read_channel(pcf_fd, 3));
```

然后你用手遮住 PCF8591 板上的光敏。

如果出现：

```text
AIN0 会变，其他不变
```

那光敏在通道 0。

如果：

```text
AIN1 会变
```

那光敏在通道 1。

如果四个都是：

```text
255 255 255 255
```

那就不像单纯通道问题，更可能是 PCF8591 接线/跳线/读取函数问题。

---

## 你现在最可能的问题

因为你之前 `i2cdetect` 已经能看到：

```text
48
```

所以 PCF8591 至少在 I2C 总线上能被识别。

如果 `Light=255` 一直不动，我优先怀疑：

```text
1. LIGHT_ADC_CHANNEL 选错了
2. 板载光敏对应的跳线帽没插
3. Agent 写的 pcf8591_read_channel() 不对
```

不是你输入了什么 GPIO 命令导致的。除非你动过：

```bash
gpio -g mode 2 out
gpio -g mode 3 out
```

否则普通 `gpio -g write 27` 这种不会影响光敏。

## 你现在要做的最小排查

先让 VS Code Agent 或你自己临时加一行，打印四路 ADC：

```c
int a0 = pcf8591_read_channel(pcf_fd, 0);
int a1 = pcf8591_read_channel(pcf_fd, 1);
int a2 = pcf8591_read_channel(pcf_fd, 2);
int a3 = pcf8591_read_channel(pcf_fd, 3);

printf("AIN0=%d AIN1=%d AIN2=%d AIN3=%d\n", a0, a1, a2, a3);
```

然后遮住光敏，看哪个值变化。

你把这四个值发我，比如：

```text
AIN0=255 AIN1=255 AIN2=78 AIN3=255
```

我就能判断是通道错、代码错，还是硬件/跳线问题。

---

# you asked

message time: 2026-06-08 06:20:21

count是啥

---

# chatgpt response

`Count` 就是**旋转编码器的计数值**，也可以理解成“转了多少个脉冲”。

你这个车辆传感器项目里，文档要求有“行驶里程计量”，也就是通过旋转编码器获取转动角度/里程。程序里的 `Count` 就是这个功能的原始数据。

简单说：

```text
你转动旋转编码器
      ↓
CLK / DT 输出脉冲
      ↓
程序检测脉冲
      ↓
Count 增加或减少
      ↓
根据 Count 换算 Mileage 里程
```

例如终端显示：

```text
Count=0
```

意思是编码器目前还没检测到转动。

如果你顺时针转，可能变成：

```text
Count=1
Count=2
Count=3
```

逆时针转，可能变成：

```text
Count=2
Count=1
Count=0
Count=-1
```

所以：

```text
Count = 编码器累计脉冲数
Mileage = 根据 Count 换算出来的模拟里程
```

如果你现在不是接轮子，只是手拧编码器，那 `Count` 就代表“手拧了多少格”，可以用来模拟车辆行驶距离。

如果你转动编码器但 `Count` 一直是 `0`，就重点检查：

```text
CLK → GPIO5
DT  → GPIO6
+   → 3.3V
GND → GND
```

`SW` 是按下旋钮的按钮脚，接 `GPIO13`，它不是转动计数必须用的。

---

# you asked

message time: 2026-06-08 06:21:10

pitch是啥

---

# chatgpt response

`Pitch` 是 **俯仰角**，表示车头/传感器板子**前后方向的倾斜角度**。

你可以这样理解：

```text
Pitch = 前后仰头/低头的角度
```

比如 MPU6050 平放时，`Pitch` 应该在某个稳定值附近。你把模块：

```text
前端抬起来 → Pitch 变化
前端压下去 → Pitch 反方向变化
```

和它对应的另一个常见角度是：

```text
Roll = 左右侧翻角
Pitch = 前后俯仰角
```

在你的车辆传感器项目里：

```text
Roll  用来判断车有没有左右侧翻
Pitch 用来判断车有没有前后大角度倾斜
```

所以程序里看到：

```text
Roll=-128
Pitch=-29
```

意思是 MPU6050 当前计算出来的左右倾斜角大约是 `-128°`，前后俯仰角大约是 `-29°`。

不过你这个 `Roll=-128` 明显不适合直接拿来判断报警，因为它静止时就很大。后面姿态报警最好改成：

```text
启动时记录初始 Roll/Pitch
之后只判断变化量
```

也就是：

```text
abs(current_pitch - base_pitch) > 35°
```

再报警，而不是直接判断 `Pitch` 本身大不大。