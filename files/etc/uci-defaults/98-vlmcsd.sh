#!/bin/sh
# 首启：vlmcsd (KMS) 默认是关闭的（/etc/config/vlmcsd enabled='0'），这里打开并启动
uci -q set vlmcsd.config.enabled='1'
uci -q commit vlmcsd
/etc/init.d/vlmcsd enable
/etc/init.d/vlmcsd restart >/dev/null 2>&1
exit 0
