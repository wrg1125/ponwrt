#!/bin/sh
uci -q set network.lan.ipaddr='10.0.0.1'
uci -q set network.lan.netmask='255.255.255.0'
uci -q set system.@system[0].zonename='Asia/Shanghai'
uci -q set system.@system[0].timezone='CST-8'
uci -q commit network
uci -q commit system
exit 0
