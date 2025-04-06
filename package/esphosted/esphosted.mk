################################################################################
#
# esphosted
#
################################################################################

ESPHOSTED_VERSION = 986ad53db44dee85363835161f861e951227e7f7
ESPHOSTED_SITE = $(call github,espressif,esp-hosted,$(ESPHOSTED_VERSION))
ESPHOSTED_DEPENDENCIES = linux
ESPHOSTED_LICENSE = GPL-2.0
ESPHOSTED_LICENSE_FILE = LICENSE
ESPHOSTED_MODULE_SUBDIRS = esp_hosted_ng/host/

define ESPHOSTED_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_NET)
	$(call KCONFIG_ENABLE_OPT,CONFIG_WIRELESS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_CFG80211)
	$(call KCONFIG_ENABLE_OPT,CONFIG_MAC80211)
	$(call KCONFIG_ENABLE_OPT,CONFIG_BT)
endef

ESPHOSTED_MODULE_MAKE_OPTS = target=sdio
ESPHOSTED_MODULE_MAKE_OPTS += ESP_SLAVE=CONFIG_TARGET_ESP32=y

$(eval $(kernel-module))
$(eval $(generic-package))
