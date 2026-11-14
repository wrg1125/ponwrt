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

# ── honk：若提供 HONK_NODE（完整 hy2 链接），首启写入配置并启用 ──
if [ -n "${HONK_NODE:-}" ]; then
  HONK_CONF="global {
	tproxy_port: 12345
	tproxy_port_protect: true
	log_level: info
	lan_interface: br-lan
	wan_interface: pppoe-wan
	auto_config_kernel_parameter: true
	dial_mode: domain
}

node {
	de: '${HONK_NODE}'
}

dns {
	upstream {
		agh: 'udp://10.0.0.1:5300'
		cf: 'https://cloudflare-dns.com/dns-query'
	}
	routing {
		request {
			qname(geosite:cn) -> agh
			qtype(aaaa) && qname(geosite:geolocation-!cn) -> reject
			fallback: cf
		}
	}
}

group {
	proxy {
		filter: name(de)
		policy: min_moving_avg
	}
}

routing {
	domain(d.5760576.xyz) -> direct
	dip(189.24.110.203) -> direct
	pname(NetworkManager, systemd-resolved, dnsmasq, AdGuardHome) -> direct
	domain(geosite:category-ads-all) && domain(geosite:geolocation-!cn) -> block
	domain(geosite:cn) -> direct
	dip(224.0.0.0/3, 'ff00::/8') -> direct
	dip(geoip:private, geoip:cn) -> direct
	fallback: proxy
}"
  {
    echo '#!/bin/sh'
    echo "cat > /etc/honk/config.dae <<'HONKCFG'"
    printf '%s\n' "$HONK_CONF"
    echo 'HONKCFG'
    echo 'chmod 600 /etc/honk/config.dae'
    echo '/etc/init.d/honk enable'
    echo '/etc/init.d/honk restart >/dev/null 2>&1'
    echo 'exit 0'
  } > files/etc/uci-defaults/98-honk.sh
  chmod 755 files/etc/uci-defaults/98-honk.sh
  echo "honk 配置已注入（节点: $(echo "$HONK_NODE" | sed -E 's#(://)[^@]*@#\1***@#')）"
else
  echo "HONK_NODE 未设置：固件带 honk 二进制 + 示例配置，需手动填节点"
fi
