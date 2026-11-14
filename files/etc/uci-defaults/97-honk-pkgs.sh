#!/bin/sh
# 首次启动：离线安装 daeuniverse 官方包（honk + luci-app-honk + 共享库）
# apk 由 CI 预置在 /etc/honk-pkgs，安装成功即删目录；失败保留便于排查
D=/etc/honk-pkgs
[ -d "$D" ] || exit 0
[ -f /etc/apk/keys/daeuniverse.pem ] || exit 0
command -v apk >/dev/null 2>&1 || exit 0

if apk add --allow-untrusted --force-overwrite --no-network "$D"/*.apk >>/tmp/honk-pkgs-install.log 2>&1; then
	rm -rf "$D"
	logger -t honk-pkgs "official honk + luci-app-honk installed"
else
	logger -t honk-pkgs "install failed, see /tmp/honk-pkgs-install.log"
fi
exit 0
