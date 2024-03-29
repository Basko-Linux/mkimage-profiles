# server distributions
ifeq (distro,$(IMAGE_CLASS))

distro/.server-base: distro/.installer use/syslinux/ui/menu use/memtest \
	use/cleanup/x11-alterator
	@$(call add,BASE_LISTS,server-base openssh)

distro/server-nano: distro/.server-base +power \
	use/install2/cleanup/vnc
	@$(call add,BASE_LISTS,$(call tags,server network))
	@$(call add,BASE_PACKAGES,dhcpcd cpio)

distro/server-mini: distro/.server-base \
	use/server/mini use/kernel/net use/efi use/power/acpi/button
	@$(call set,INSTALLER,altlinux-server)
	@$(call add,BASE_PACKAGES,make-initrd-mdadm make-initrd-lvm)

distro/server-mini-systemd-networkd: distro/.server-base \
	use/net/networkd +systemd \
	use/server/mini use/efi use/firmware
	@$(call set,INSTALLER,altlinux-server)

ifneq (,$(filter-out x86_64 aarch64,$(ARCH)))
distro/server-ovz: distro/server-mini use/server/ovz use/server/groups/base \
	use/install2/net use/hdt use/rescue \
	use/firmware/server use/firmware/cpu +wireless; @:
endif

distro/server-zabbix: distro/server-mini use/server/zabbix; @:

endif
