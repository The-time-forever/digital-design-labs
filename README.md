# 数字设计与计算机原理实验

> Zynq-7000 与树莓派上的八个实验工程，涵盖逻辑函数、译码器、LED 分频闪烁、乘法器、汉明码纠错、音乐播放器、PS/PL 互控 LED 和车辆传感器综合系统，另附实验报告与素材。

![Vivado](https://img.shields.io/badge/Vivado-2018.3-blue)
![Device](https://img.shields.io/badge/device-xc7z010clg400--1-orange)
![HDL](https://img.shields.io/badge/HDL-Verilog%20%7C%20SystemVerilog-success)
![Reports](https://img.shields.io/badge/reports-XeLaTeX%20%7C%20pdfLaTeX-lightgrey)
![LFS](https://img.shields.io/badge/binaries-Git%20LFS-informational)

## 目录

- [项目简介](#项目简介)
- [实验一览](#实验一览)
- [目录结构](#目录结构)
- [使用方法](#使用方法)
- [效果截图](#效果截图)
- [致谢](#致谢)
- [许可与使用范围](#许可与使用范围)

## 项目简介

这是“数字设计与计算机原理”课程的实验归档，包含七个 Xilinx Vivado 工程（Zynq-7000，
器件 `xc7z010clg400-1`）、一个树莓派 4B 的 C 工程，以及实验报告的 LaTeX 源文件与成品 PDF。

**做了什么**

1. **用数据选择器实现任意逻辑函数** —— 不给 MUX 喂变量，而是喂常数真值表，一个 4 选 1
   选择器就变成一个 2 输入查找表（LUT）。这是理解 FPGA 内部结构的最小可运行例子。
2. **汉明码（7,4）编解码与纠错** —— 纯组合逻辑：编码、人为注入错误、由伴随式（syndrome）
   定位并翻转错误位，再把纠正后的数据解出来。
3. **动漫音乐播放器** —— 50 MHz 时钟分频出音高、乐谱 ROM 调度音符、74HC595 三线驱动
   8 位数码管、按键消抖，另外做了音乐/时钟（闹钟）双模式。
4. **PS 与 PL 互控 LED** —— Zynq 的 PS 端 C 程序（`XGpioPs`）读 MIO/EMIO 按键，
   交叉点亮对方的 LED，用来理解 PS 与 PL 的边界。
5. **树莓派车辆传感器综合系统** —— 自动大灯、自动雨刷、超声波测距报警、编码器里程计量、
   MPU6050 姿态检测，五项功能共用一条 I2C 总线和 100 ms 主循环。
6. **3 线–8 线译码器** —— 用 `case` 将三位拨码输入译成八位独热码，每种输入只点亮对应的一盏 LED。
7. **LED 分频闪烁** —— 用 26 位计数器对 50 MHz 时钟计数，每秒翻转一次 LED，完整闪烁周期为 2 秒。
8. **4×4 位无符号乘法器** —— 将两个四位拨码输入相乘，用全加器构成的串行进位加法器累加四组部分积，
   再用八盏 LED 显示乘积。

**为什么这样组织**

- 硬件逻辑使用 **Verilog** 和 **SystemVerilog**。译码器和 LED 闪烁使用 Verilog，乘法器使用 SystemVerilog。
- 报告统一用 **ctexart**，中文排版交给 `ctex`；实验 1 是 `pdfLaTeX`（MiKTeX），实验 2、3
  是 `XeLaTeX`（TeX Live）——沿用了当时的编译环境，没有为了统一而重排。
- 二进制素材（照片、PDF、Word）走 **Git LFS**，源码与约束留在普通 Git，克隆后
  `git lfs pull` 就能拿到全部原图。

**难点**

- 音符时长不能靠"循环次数"硬凑：要按 50 MHz 换算成 tick，还得让换曲、暂停、变速共用
  同一套调度状态机。
- 汉明码的位序很容易和教科书对不上：`code_out = {B8, B4, B2, P3, B1, P2, P1}`，
  syndrome 的三位权重要与 `pos_mask` 的 7 位掩码逐一对应。
- 树莓派的 wiringPi 用的是 BCM 编号而不是物理引脚号；PCF8591 与 MPU6050 挂在同一条
  I2C 上，初始化顺序写错会读到上一次的转换结果。

## 实验一览

| 目录 | 题目 | 平台 | 实现要点 | 状态 |
|---|---|---|---|---|
| `mux4_1_lut/` | 组合逻辑：MUX 实现逻辑函数 | Zynq PL | `mux4_1.sv` + 4 个常数 MUX 搭出 AND/OR/XOR/NAND | 综合/实现/比特流完成，2 个 testbench |
| `实验1/` | 汉明码编解码 | Zynq PL | 编码、注入错误、syndrome 定位、纠正 | 完成，有自检 testbench |
| `实验2/` | 动漫音乐播放器 | Zynq PL | 分频、乐谱 ROM、74HC595、数码管扫描、时钟/闹钟 | 完成，上板验证（无 testbench） |
| `key_ctrl_led/` | PS/PL 按键互控 LED | Zynq PS+PL | Block Design + SDK C 程序（`XGpioPs`） | 完成（BSP 需用 `.hdf` 重建） |
| `实验3/` | 车辆传感器综合实验 | 树莓派 4B | wiringPi + I2C，五项功能 | 完成，上板验证 |
| `decoder3_8/` | 3 线–8 线译码器 | Zynq PL | SW0–SW2 输入三位编码，LED0–LED7 显示译码结果 | 有 testbench，覆盖 8 种输入 |
| `led_flash/` | LED 分频闪烁 | Zynq PL | 26 位计数器、低有效异步复位、LED 定时翻转 | 含 RTL 和引脚约束 |
| `mul4x4/` | 4×4 位无符号乘法器 | Zynq PL | SW0–SW3 和 SW4–SW7 分别输入两个操作数，LED0–LED7 显示乘积 | 有自检 testbench，覆盖 256 种输入 |

## 目录结构

```
.
├── README.md
├── .gitignore            Vivado / SDK / LaTeX 生成物
├── .gitattributes        Git LFS 规则（图片、PDF、Word）
├── mux4_1_lut/           4 选 1 选择器 → 逻辑函数（LUT）
│   ├── mux4_1_lut.xpr
│   └── mux4_1_lut.srcs/  sources_1(设计) constrs_1(xdc) sim_1(testbench)
├── 实验1/                 汉明码
│   ├── hamming_code/     Vivado 工程
│   ├── 实验报告.tex/.pdf
│   ├── schematic*.pdf    RTL 原理图
│   ├── simulation_wave.png
│   └── 原始照片/         上板演示的手机原图（HEIC）
├── 实验2/                 音乐播放器
│   ├── anime_music_player/
│   ├── 实验报告.tex/.pdf
│   ├── 系统使用说明书.tex/.pdf
│   ├── 实现流程详解.md
│   ├── figures/          报告插图
│   └── 原始照片/
├── 实验3/                 树莓派车辆传感器
│   ├── automatic_car/    C 源码 + makefile + spec.md
│   ├── 车辆传感器综合实验报告.tex/.pdf
│   ├── report_assets/    报告插图
│   └── 原始照片/
├── key_ctrl_led/         Vivado 工程 + key_ctrl_led.sdk/（SDK 工作区）
├── decoder3_8/           3 线–8 线译码器
├── led_flash/            LED 分频闪烁
├── mul4x4/               4×4 位无符号乘法器
└── docs/                 课程教程 PDF、树莓派指导书、Win10 网络共享笔记
```

## 使用方法

### 1. `mux4_1_lut` —— 用 MUX 实现逻辑函数

打开 `mux4_1_lut.xpr`，顶层是 `mux4_1_top`。

| 拨码 / LED | 引脚 | 作用 |
|---|---|---|
| SW0–SW3 | K14 / L15 / G14 / J14 | 数据 `din[3:0]` |
| SW4–SW5 | F16 / H15 | 选择 `sel[1:0]` |
| LED0 | G17 | 被选中的那一位（`led[0] = din[sel]`） |
| LED1–LED4 | G19 / G20 / G18 / K19 | 回显 `din` |
| LED5–LED6 | J18 / H17 | 回显 `sel` |

拨 SW4/SW5 时 LED0 应在 SW0→SW3 之间跳，LED1–LED4 不动，方便对照输入。

要看"LUT"版本，把 `logic_lut_top.sv` 设为顶层再综合：`sel` 变成功能选择（00 AND /
01 OR / 10 XOR / 11 NAND），数据只用 SW0、SW1 两位。

### 2. `实验1/hamming_code` —— 汉明码

打开 `实验1/hamming_code/hamming_code.xpr`，顶层 `hamming_code_top`。

| 拨码 | 引脚 | 作用 |
|---|---|---|
| SW0–SW3 | K14 / L15 / G14 / J14 | 4 位数据 `data_in` |
| SW4–SW6 | F16 / H15 / D18 | 人为错误位置 `err_pos`（0 = 不注入，1–7 = 翻转该位） |

| LED | 引脚 | 含义 |
|---|---|---|
| LED0–LED2 | G17 / G19 / G20 | syndrome（0 表示没错，否则为出错位） |
| LED3–LED6 | G18 / K19 / J18 / H17 | 纠错后解出的 4 位数据 |
| LED7 | K18 | `error_flag`，有错即亮 |

演示流程：`data_in = 0100`、`err_pos = 0` 时 LED3–LED6 重现 0100；把 `err_pos` 拨到 1 或 2，
LED7 亮、LED0–2 给出错误位置，纠错后的数据仍是 0100。报告里的 `demo_initial_0100.jpg`、
`demo_error_pos1/2.jpg` 就是这组现象。

### 3. `实验2/anime_music_player` —— 动漫音乐播放器

打开 `实验2/anime_music_player/anime_music_player.xpr`，顶层 `anime_music_player_top`。
系统时钟 50 MHz（U18），复位是 EDA 扩展板的 S4（H18，低有效）。

音乐模式（SW7 = 0）：

| 控件 | 引脚 | 作用 |
|---|---|---|
| S0 | H20 | 播放 / 暂停 |
| S1 | H16 | 下一首（内置 4 首，`song_id` 0–3） |
| S2 / S3 | J20 / J19 | 加速 / 减速 |
| SW0–SW1 | K14 / L15 | 音量（PWM 占空比） |
| 蜂鸣器 | G15 | 出声 |

时钟模式（SW7 = 1，E17）：数码管显示 `HH-MM-SS`，S0 选字段、S1/S2 加减、S3 暂停；
`SW2–SW3` 选闹铃曲，`SW5` 开闹铃，`SW6` 进入设置。

LED 含义随模式切换：音乐模式 `[7:5]` 节奏、`[4:3]` 速度、`[2:1]` 歌曲、`[0]` 播放中；
时钟模式 `[7]` 1 Hz 闪烁、`[6]` 闹铃响、`[2:1]` 设置字段、`[0]` 走时。
数码管经 `hc595_driver` 三线（D20 / E19 / F17）驱动，扫描译码在 `hex8_scan` 里。

### 4. `key_ctrl_led` —— PS 与 PL 互控

1. Vivado 打开 `key_ctrl_led.xpr`（Block Design `system` 里只有 `processing_system7`，
   EMIO 引到 T14 / F20），跑完综合实现后 `File → Export → Export Hardware`（勾选比特流），
   得到 `.hdf`。
2. SDK 2018.3 打开 `key_ctrl_led.sdk` 工作区；BSP 未入库，按 `system.mss` 重新生成
   （standalone 即可）。
3. Build `key_ctrl_led`，下载运行。

行为（`src/main.c`）：PS 按键（MIO47）→ PL 灯（EMIO0，F20）亮；PL 按键（EMIO1，T14）→
PS 灯（MIO7）亮；松开熄灭。`ACZ702_Lib/PS_GPIO` 是对 `XGpioPs` 的一层薄封装。

### 5. `实验3/automatic_car` —— 树莓派车辆传感器

```bash
cd 实验3/automatic_car
make            # gcc -lwiringPi -lm -lpthread
sudo ./automatic_car
```

`makefile` 用了 `.RECIPEPREFIX := >`（GNU make ≥ 4.3 的写法，避免 tab 被编辑器吃掉）。

引脚与阈值都在 `config.h` 里，改一处即可复用：

| 功能 | 传感器 / 器件 | 关键配置 |
|---|---|---|
| 自动大灯 | PCF8591 光敏（I2C 0x48，通道 1） | `LIGHT_DARK_THRESHOLD 120`，暗则点亮 LED（BCM 17） |
| 自动雨刷 | 雨滴传感器 DO（BCM 22） | 低有效，LCD 显示 `Raining` / `No Rain` |
| 障碍报警 | HC-SR04（TRIG 23 / ECHO 24） | 30 cm 警告、10 cm 报警，蜂鸣器 BCM 27 |
| 里程计量 | 旋转编码器（CLK 5 / DT 6 / SW 13） | 20 脉冲/圈，轮径 6.5 cm |
| 姿态感知 | MPU6050（I2C 0x68） | Roll/Pitch 倾斜 > 35° 报警，LCD1602（I2C 0x27）分页显示 |

主循环 100 ms，LCD 每 2 s 换一页（`DISPLAY_PAGE_MS`），五页对应五项功能。

## 效果截图

| 组合逻辑仿真 | 音乐播放器上板 | 树莓派小车硬件 |
|---|---|---|
| ![仿真波形](实验1/simulation_wave.png) | ![上板](实验2/figures/board_demo_01.jpg) | ![硬件](实验3/report_assets/hardware_overview.jpg) |

更多现象照片在 `实验1/原始照片/`、`实验3/report_assets/`，报告 PDF 里有完整截图。

## 致谢

- 课程组提供的《数字设计与嵌入式系统实验教程》与树莓派实验指导书（`docs/`）。
- ACZ702 开发板的 `ACZ702_Lib`（`key_ctrl_led.sdk` 里的 PS GPIO 封装）。
- [wiringPi](http://wiringpi.com/)（Gordon Henderson）提供树莓派的 GPIO / I2C 封装。
- `ctex` 宏包与 CTeX 社区的中文文档方案；`latexmk`、`pdfcrop` 负责编译与裁图。
- 报告排版参考了实验指导书的章节结构，`schematic*.pdf` 来自 Vivado 的 RTL 原理图导出。

## 许可与使用范围

仓库中的代码是个人课程作业，仅用于学习与复现，未附开源许可证——即默认保留所有权利。
`docs/` 下的教程、指导书以及 `ACZ702_Lib` 的版权归课程组与板卡厂商，请勿再分发。
实验报告（PDF 与 LaTeX 源）请勿直接提交为他人作业。
