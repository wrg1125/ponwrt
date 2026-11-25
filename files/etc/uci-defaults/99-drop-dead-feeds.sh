#!/bin/sh
# 镜像构建时会把 distfeeds.list 按 feeds.conf.default 全量生成，其中
#   pon_drivers / pon_userspace  (PonWrt 私有源，downloads.immortalwrt.org 从未托管)
#   video                        (官方镜像已下架)
# 三个 URL 都是 404，导致 `apk update` 以 exit 3 失败、LuCI 软件包管理器一直报
# "wget: exited with error 8 / unexpected end of file"。这里在首次启动、UI 起来
# 之前把它们从源列表里摘掉。脚本本身会被 uci-defaults 执行后自动删除。
DL=/etc/apk/repositories.d/distfeeds.list
[ -f "$DL" ] || exit 0

if grep -qE '/(pon_drivers|pon_userspace|video)/packages\.adb' "$DL"; then
	T=$(mktemp)
	grep -vE '/(pon_drivers|pon_userspace|video)/packages\.adb' "$DL" > "$T"
	cat "$T" > "$DL"
	rm -f "$T"
	logger -t drop-dead-feeds "已移除 3 个不存在的 apk 源"
fi

exit 0
