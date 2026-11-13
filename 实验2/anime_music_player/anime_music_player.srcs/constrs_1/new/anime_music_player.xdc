# 50MHz system clock
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 20.000 -name clk [get_ports clk]

# Reset, active low
# ʹ�� EDA ��չ�� S4 ��Ϊ��λ��
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS33} [get_ports reset_n]

# Buzzer, on ACZ702 main board
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports beep]

# EDA expansion board keys
# S0: ���� / ��ͣ
set_property -dict {PACKAGE_PIN H20 IOSTANDARD LVCMOS33} [get_ports key0]

# S1: ��һ��
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports key1]

# S2: ����
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33} [get_ports key2]

# S3: ����
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports key3]

# EDA expansion board LEDs
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {led[7]}]

# 74HC595 for 8-digit seven-segment display
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports seg_dio]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports seg_sclk]
set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS33} [get_ports seg_rclk]

# EDA expansion board switches for volume control
set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports {sw_vol[0]}]
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports {sw_vol[1]}]

# SW7: mode switch  0=music  1=clock
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports sw_mode]

# Alarm switches
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {sw_alarm_song[0]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {sw_alarm_song[1]}]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports sw_alarm_en]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports sw_alarm_set]