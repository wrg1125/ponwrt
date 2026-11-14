#
# honk — dae 团队的 Rust 重写版透明代理引擎（eBPF 数据面）
# 直接使用上游 aarch64 musl 预编译二进制（-stock = 系统分配器，省内存）
#
include $(TOPDIR)/rules.mk

PKG_NAME:=honk
PKG_VERSION:=0.1.0-beta.6
PKG_RELEASE:=1

PKG_SOURCE:=honk-core-v$(PKG_VERSION)-aarch64-unknown-linux-musl-stock-clash-api.tar.gz
PKG_SOURCE_URL:=https://github.com/daeuniverse/honk/releases/download/v$(PKG_VERSION)
PKG_HASH:=e33320460ed1cda83b21cfc3a0551769a1a250c0aeeda5824e92f18d322fb69e
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK:=tar -C $(PKG_BUILD_DIR) -xzf $(DL_DIR)/$(PKG_SOURCE) --strip-components=1

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/honk
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=honk - eBPF transparent proxy engine (Rust, dae-compatible config)
  URL:=https://github.com/daeuniverse/honk
  DEPENDS:=+kmod-veth +kmod-nft-queue +kmod-nft-core +kmod-nf-conntrack +kmod-sched-core \
	+v2ray-geosite +v2ray-geoip
endef

define Package/honk/description
 honk 是 dae 团队用 Rust 重写的 Linux 透明代理引擎：TC eBPF 数据面、
 dae 配置语法、sing-box 风格出站组（Selector/URLTest/LoadBalance/Fallback/Score）、
 Clash 兼容 REST/WebSocket API。出站支持 SOCKS5/SS2022/Trojan/AnyTLS/
 Hysteria2/TUIC/Juicity/VMess/VLESS（含 H2 XHTTP：packet-up/stream-up/stream-one）。

 要求：root、Linux 6.12+、cgroup v2、bpffs。默认关闭，启用前请先备份配置。
endef

define Build/Compile
endef

define Package/honk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/honk-core $(1)/usr/bin/honk
	$(INSTALL_DIR) $(1)/etc/honk
	$(INSTALL_CONF) ./files/config.dae $(1)/etc/honk/config.dae
	$(INSTALL_CONF) ./files/config.dae.example $(1)/etc/honk/config.dae.example
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/honk.init $(1)/etc/init.d/honk
endef

$(eval $(call BuildPackage,honk))
