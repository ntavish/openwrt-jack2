#
# Copyright (C) 2007 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# blogic@openwrt.org
# tavishnaruka@gmail.com
#
# help here https://wiki.samba.org/index.php/Waf#cross-compiling

include $(TOPDIR)/rules.mk

PKG_NAME:=jack2
PKG_VERSION:=v1.9.10
PKG_SOURCE_VERSION:=3eb0ae6affbe4cd5038e846ad8e804c80e9cc012
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/jackaudio/jack2.git
PKG_SOURCE_PROTO:=git
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
include $(INCLUDE_DIR)/package.mk

define Package/jack-audio-connection-kit/Default
	SECTION:=sound
	CATEGORY:=Sound
	URL:=http://jackaudio.org
	DEPENDS:=+AUDIO_SUPPORT:alsa-lib +libsamplerate +libstdc++ +libc +libjack +librt
endef
 
CC="$(TARGET_CC)"
CFLAGS="$(TARGET_CFLAGS)"
LDFLAGS="$(TARGET_LDFLAGS)"
LIBS="$(TARGET_LIBS)"

define Package/jack-audio-connection-kit
	$(call Package/jack-audio-connection-kit/Default)
	TITLE:=jack-audio-connection-kit
	MENU:=1
endef

define Package/jack-audio-connection-kit/description
	jack audio server
endef

define Package/libjack
	$(call Package/jack-audio-connection-kit/Default)
	TITLE:=libjack
	DEPENDS:=jack-audio-connection-kit +libstdc++
endef

define Package/libjack/description
	jack encoder  libs
endef

define Package/drivers
	$(call package/jack-audio-connectoion-kit/Default)
	TITLE=drivers
	DEPENDS:=jack-audio-connection-kit
endef

define Package/drivers/description
	jack drivers  libs
endef

define Build/Configure
	$(INSTALL_DIR) $(PKG_BUILD_DIR)/installed
	(cd $(PKG_BUILD_DIR); \
		CC="$(TARGET_CC)" \
		CXX="$(TARGET_CXX)" \
		CXXFLAGS="$(TARGET_CXXFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LIBS="$(TARGET_LIBS)" $(HOST_DIR)/usr/bin/python2 ./waf configure \
			--prefix=$(PKG_BUILD_DIR)/installed \
			--alsa \
	)
endef

define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		CC="$(TARGET_CC)" \
		CXX="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CXXFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LIBS="$(TARGET_LIBS)" $(HOST_DIR)/usr/bin/python2 ./waf build -j4; \
		CC="$(TARGET_CC)" \
		CXX="$(TARGET_CXX)" \
		CXXFLAGS="$(TARGET_CXXFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LIBS="$(TARGET_LIBS)" $(HOST_DIR)/usr/bin/python2 ./waf install; \
	)
endef

define Package/jack-audio-connection-kit/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/installed/bin/jackd $(1)/usr/bin/
endef

define Package/libjack/install
		$(INSTALL_DIR) $(1)/usr/lib
		# $(CP) $(PKG_BUILD_DIR)/installed/lib/lib*so* $(1)/usr/lib/
		$(CP) $(PKG_BUILD_DIR)/build/common/libjack.so.0 $(1)/usr/lib/
		$(CP) $(PKG_BUILD_DIR)/build/common/libjackserver.so.0 $(1)/usr/lib/
		$(CP) $(PKG_BUILD_DIR)/build/common/libjacknet.so.0 $(1)/usr/lib/
endef

define Package/drivers/install
		$(INSTALL_DIR) $(1)/usr/lib/jack
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/installed/lib/jack/*so* $(1)/usr/lib/jack/
endef

define Build/InstallDev
		mkdir -p $(1)/usr/{lib,include}
		${CP} $(PKG_BUILD_DIR)/installed/{lib,include} $(1)/usr/

endef

$(eval $(call BuildPackage,libjack))
$(eval $(call BuildPackage,drivers))
$(eval $(call BuildPackage,jack-audio-connection-kit))