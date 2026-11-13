# =========================
# Input: SW0~SW3 -> din[3:0]
# =========================
set_property PACKAGE_PIN K14 [get_ports {din[0]}]
set_property PACKAGE_PIN L15 [get_ports {din[1]}]
set_property PACKAGE_PIN G14 [get_ports {din[2]}]
set_property PACKAGE_PIN J14 [get_ports {din[3]}]

# =========================
# Input: SW4~SW5 -> sel[1:0]
# sel[0] = SW4
# sel[1] = SW5
# =========================
set_property PACKAGE_PIN F16 [get_ports {sel[0]}]
set_property PACKAGE_PIN H15 [get_ports {sel[1]}]

# =========================
# Output: LED0~LED7
# =========================
set_property PACKAGE_PIN G17 [get_ports {led[0]}]
set_property PACKAGE_PIN G19 [get_ports {led[1]}]
set_property PACKAGE_PIN G20 [get_ports {led[2]}]
set_property PACKAGE_PIN G18 [get_ports {led[3]}]
set_property PACKAGE_PIN K19 [get_ports {led[4]}]
set_property PACKAGE_PIN J18 [get_ports {led[5]}]
set_property PACKAGE_PIN H17 [get_ports {led[6]}]
set_property PACKAGE_PIN K18 [get_ports {led[7]}]

# =========================
# I/O Standard
# =========================
set_property IOSTANDARD LVCMOS33 [get_ports {din[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sel[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]