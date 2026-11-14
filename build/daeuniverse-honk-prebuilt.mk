#
# OpenWrt package: honk — 预编译二进制版（PonWrt / XG2010G 用）
#
# 上游 daeuniverse/openwrt-packages 的 honk/Makefile 要求把 honk 源码放在 ./src，
# 构建时要 rustup nightly + bpf-linker + 交叉编译 BoringSSL/SQLite，单包就要一两个小时。
# 这里改为直接取官方 release 的 aarch64 musl full 包（自带 clash-api + native-api +
# 内嵌 doona 面板），安装布局 / init / UCI / 依赖均与上游保持一致。
#
# 工作流里的用法：
#   cp build/daeuniverse-honk-prebuilt.mk feeds/daeuniverse/honk/Makefile
#

PKG_NAME:=honk
PKG_VERSION:=0.1.0_beta6
PKG_RELEASE:=1

PKG_SOURCE:=honk-core-v0.1.0-beta.6-aarch64-unknown-linux-musl-full.tar.gz
PKG_SOURCE_URL:=https://github.com/daeuniverse/honk/releases/download/v0.1.0-beta.6
PKG_HASH:=5e4c0359950e0f19fac53e31ef9ffbe9f0aafca92331c3fa81e5b56212950a6e

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

# $(CURDIR) 是 buildroot 根，先解析出本 Makefile 所在目录（= feed 里的 honk/）
PKG_DIR:=$(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

PKG_BUILD_DIR:=$(BUILD_DIR)/honk-prebuilt-$(PKG_VERSION)

# release 包内层目录名带架构后缀，一律剥掉，落到 PKG_BUILD_DIR 根下
PKG_UNPACK:=mkdir -p $(PKG_BUILD_DIR) && tar -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/honk
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=eBPF transparent proxy engine (honk-core) with embedded UI (prebuilt)
  URL:=https://github.com/daeuniverse/honk
  LICENSE:=GPL-3.0-only
  # 本内核自带 BTF（/sys/kernel/btf/vmlinux），用 vmlinux-btf-builtin 顶替 vmlinux-btf
  DEPENDS:=+libstdcpp +kmod-veth +kmod-sched-core +kmod-sched-bpf \
           +kmod-nft-core +kmod-nft-queue +kmod-nfnetlink-queue \
           +kmod-nf-conntrack +vmlinux-btf-builtin +v2ray-geoip +v2ray-geosite
endef

define Package/honk/description
 honk is an eBPF transparent proxy engine. This package installs the upstream
 prebuilt release binary (aarch64 musl full build: Clash API, native API and the
 embedded doona dashboard served at /ui on the native API listener) instead of
 building the Rust sources in-tree.
endef

define Build/Compile
	true
endef

define Package/honk/conffiles
/etc/config/honk
/etc/honk/config.dae
endef

define Package/honk/preinst
#!/bin/sh
[ -z "$${IPKG_INSTROOT}" ] || exit 0
enabled="$$(uci -q get honk.config.enabled)"
[ -z "$$enabled" ] || echo "$$enabled" > /tmp/honk-autostart
exit 0
endef

define Package/honk/postinst
#!/bin/sh
[ -z "$${IPKG_INSTROOT}" ] || exit 0
/etc/init.d/honk enabled && /etc/init.d/honk restart
exit 0
endef

define Package/honk/install
	test -f $(PKG_BUILD_DIR)/honk-core || { echo "honk-core not found in $(PKG_BUILD_DIR):"; ls -la $(PKG_BUILD_DIR); exit 1; }
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/honk-core $(1)/usr/bin/honk-core
	$(INSTALL_DIR) $(1)/usr/share/licenses/honk
	if [ -f $(PKG_BUILD_DIR)/LICENSE ]; then \
		$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/licenses/honk/LICENSE; \
	else \
		echo "Copyright (C) daeuniverse; honk is licensed GPL-3.0-only." > $(1)/usr/share/licenses/honk/LICENSE; \
	fi
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_DIR)/files/honk.init $(1)/etc/init.d/honk
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_DIR)/files/honk.config $(1)/etc/config/honk
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_DIR)/files/honk.uci-defaults $(1)/etc/uci-defaults/90-honk-autostart
	$(INSTALL_DIR) $(1)/etc/honk
	$(INSTALL_CONF) $(PKG_DIR)/files/config.dae $(1)/etc/honk/config.dae
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	printf '%s\n' '/etc/honk/data/' > $(1)/lib/upgrade/keep.d/honk
	$(INSTALL_DIR) $(1)/usr/share/honk
	$(LN) ../v2ray/geoip.dat $(1)/usr/share/honk/geoip.dat
	$(LN) ../v2ray/geosite.dat $(1)/usr/share/honk/geosite.dat
endef

$(eval $(call BuildPackage,honk))
