#!/bin/bash
set -e
[ -n "$ROOT_HASH" ] || { echo "ROOT_HASH missing"; exit 1; }
[ -n "$PPPoE_USER" ] && [ -n "$PPPoE_PASS" ] || { echo "PPPoE creds missing"; exit 1; }
mkdir -p files/etc/uci-defaults
printf '%s\n' \
  "root:${ROOT_HASH}:0:0:99999:7:::" \
  "daemon:*:0:0:99999:7:::" "bin:*:0:0:99999:7:::" "sys:*:0:0:99999:7:::" \
  "sync:*:0:0:99999:7:::" "mail:*:0:0:99999:7:::" "man:*:0:0:99999:7:::" \
  "ftp:*:0:0:99999:7:::" "nobody:*:0:0:99999:7:::" > files/etc/shadow
{
  echo '#!/bin/sh'
  echo "uci -q set network.wan.proto='pppoe'"
  echo "uci -q set network.wan.username='${PPPoE_USER}'"
  echo "uci -q set network.wan.password='${PPPoE_PASS}'"
  echo 'uci -q del network.wan.ipaddr 2>/dev/null'
  echo 'uci -q del network.wan.netmask 2>/dev/null'
  echo 'uci -q commit network'
  echo 'exit 0'
} > files/etc/uci-defaults/99-wrg-pppoe.sh
chmod 755 files/etc/uci-defaults/99-wrg-pppoe.sh
echo "inject OK: shadow $(wc -l < files/etc/shadow) 行, pppoe defaults 已渲染"
