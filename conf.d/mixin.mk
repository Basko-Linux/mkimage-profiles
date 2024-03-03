### various mixins with their origin

### desktop.mk
mixin/desktop-installer: +vmguest \
	use/bootloader/os-prober use/x11-autostart use/fonts/install2 use/sound
	@$(call add,BASE_LISTS, \
		$(call tags,(base || desktop) && (l10n || network)))
	@$(call add,INSTALL2_PACKAGES,ntfs-3g)

### e2k.mk
mixin/e2k-base: use/tty/S0 use/net-eth/dhcp; @:

mixin/e2k-desktop: use/e2k/x11 use/l10n/default/ru_RU \
	use/browser/firefox/esr use/browser/firefox \
	use/fonts/otf/adobe use/fonts/otf/mozilla
	@$(call add,THE_PACKAGES,xinit xterm mc)
	@$(call add,THE_PACKAGES,fonts-bitmap-terminus)

mixin/e2k-livecd-install: use/e2k/x11
	@$(call add,THE_PACKAGES,livecd-install)
	@$(call add,THE_PACKAGES,fdisk hdparm rsync openssh vim-console)
	@$(call add,THE_PACKAGES,apt-repo)

mixin/e2k-mate: use/e2k/x11 use/x11/xorg use/fonts/install2 \
	use/deflogin/live use/deflogin/xgrp \
	use/x11/mate use/x11/lightdm/slick \
	use/fonts/otf/adobe use/fonts/otf/mozilla \
	use/fonts/ttf/google use/fonts/ttf/redhat
	@$(call set,INSTALLER,altlinux-desktop)
	@$(call add,THE_BRANDING,mate-settings)
	@$(call add,THE_BRANDING,alterator)
	@$(call add,THE_BRANDING,graphics)
	@$(call add,THE_PACKAGES,setup-mate-terminal)
	@$(call add,THE_PACKAGES,setup-mate-nocomposite)
	@$(call add,THE_PACKAGES,alterator-standalone)
	@$(call add,THE_PACKAGES,terminfo-extra)
	@$(call add,THE_PACKAGES,ethtool net-tools ifplugd)
	@$(call add,THE_PACKAGES,zsh bash-completion)

mixin/vm-archdep:: use/auto-resize; @:

ifeq (,$(filter-out i586 x86_64 aarch64,$(ARCH)))
mixin/vm-archdep:: +efi
ifeq (,$(filter-out p10,$(BRANCH)))
	@$(call set,KFLAVOURS,un-def)
else
	@$(call set,KFLAVOURS,std-def un-def)
endif
endif

ifeq (,$(filter-out armh,$(ARCH)))
mixin/vm-archdep::
	@$(call set,KFLAVOURS,un-def mp)
endif


ifeq (,$(filter-out armh aarch64,$(ARCH)))
mixin/vm-archdep:: use/bootloader/uboot use/no-sleep use/arm-rpi4; @:
endif

ifeq (,$(filter-out mipsel,$(ARCH)))
mixin/vm-archdep:: use/tty/S0
	@$(call set,KFLAVOURS,un-malta)
endif

ifeq (,$(filter-out riscv64,$(ARCH)))
mixin/vm-archdep:: use/bootloader/uboot
	@$(call set,KFLAVOURS,un-def)
endif

mixin/vm-archdep-x11: mixin/vm-archdep use/vmguest/kvm/x11; @:

### regular.mk
mixin/regular-x11: use/browser/firefox \
	use/branding use/ntp/chrony use/services/lvm2-disable
	@$(call add,THE_LISTS,$(call tags,(base || desktop) && regular && !extra))
	@$(call add,THE_PACKAGES,disable-usb-autosuspend)
	@$(call add,THE_PACKAGES,btrfs-progs)
	@$(call add,THE_PACKAGES,gpm)
	@$(call add,DEFAULT_SERVICES_DISABLE,gpm powertop)
ifneq (sisyphus,$(BRANCH))
	@$(call set,FX_FLAVOUR,-esr)
endif

# common WM live/installer bits
mixin/regular-desktop: +alsa +nm-native \
	use/x11/xorg use/xdg-user-dirs use/l10n \
	use/fonts/otf/adobe use/fonts/otf/mozilla use/branding/notes
	@$(call set,LOCALES,en_US ru_RU pt_BR)
	@$(call add,THE_PACKAGES,pam-limits-desktop beesu polkit dvd+rw-tools)
	@$(call add,THE_BRANDING,alterator graphics indexhtml)
ifneq (,$(filter-out e2k%,$(ARCH)))
	@$(call add,THE_BRANDING,notes)
endif
	@$(call add,THE_PACKAGES,$$(THE_IMAGEWRITER))
	@$(call set,THE_IMAGEWRITER,altmediawriter)
	@$(call add,THE_PACKAGES,upower udev-rules-rfkill-uaccess)
	@$(call add,DEFAULT_SERVICES_DISABLE,gssd idmapd krb5kdc rpcbind)
	@$(call add,DEFAULT_SERVICES_ENABLE,cups)
	@$(call add,DEFAULT_SERVICES_ENABLE,alteratord)
	@$(call add,CONTROL,fusermount:public)
	@$(call add,CONTROL,libnss-role:disabled)

mixin/desktop-extra:
	@$(call add,BASE_LISTS,$(call tags,(archive || base) && extra))

mixin/regular-wmaker: use/fonts/ttf/redhat use/x11/wmaker +nm-gtk
	@$(call add,LIVE_PACKAGES,installer-feature-no-xconsole-stage3)
	@$(call add,MAIN_PACKAGES,wmgtemp wmhdaps wmxkbru xxkb)

mixin/regular-icewm: use/fonts/ttf/redhat +icewm +nm-gtk
	@$(call add,THE_LISTS,$(call tags,regular icewm))
	@$(call add,THE_PACKAGES,icewm-startup-networkmanager)
	@$(call add,THE_PACKAGES,mnt)

# gdm2.20 can reboot/halt with both sysvinit and systemd, and is slim
mixin/regular-gnustep: use/x11/gnustep use/mediacheck
	@$(call add,THE_BRANDING,graphics)

mixin/regular-cinnamon: use/x11/cinnamon use/x11/lightdm/slick +nm-gtk \
	use/fonts/ttf/google use/im
	@$(call add,THE_PACKAGES,xdg-user-dirs-gtk)
	@$(call add,THE_PACKAGES,gnome-disk-utility gnome-system-monitor)

mixin/regular-deepin: use/x11/deepin use/browser/chromium +nm; @:

mixin/regular-gnome: use/x11/gnome use/fonts/ttf/redhat +nm-gtk4
	@$(call add,THE_PACKAGES,power-profiles-daemon)
	@$(call add,THE_PACKAGES,gnome-terminal)
	@$(call add,THE_PACKAGES,gnome-software)
	@$(call add,PINNED_PACKAGES,gnome-terminal:Required)
	@$(call add,THE_PACKAGES,chrome-gnome-shell)
	@$(call add,THE_PACKAGES,qt5-wayland qt6-wayland)
	@$(call add,THE_PACKAGES,cups-pk-helper cups)
	@$(call add,THE_PACKAGES,eepm)
	@$(call add,THE_PACKAGES,fonts-ttf-lxgw-wenkai)

mixin/regular-kde5: use/x11/kde5 use/browser/falkon \
	use/x11/kde5-display-manager-lightdm \
	use/fonts/ttf/google use/fonts/ttf/redhat use/fonts/zerg
	@$(call add,THE_PACKAGES,plasma5-xdg-desktop-portal-kde)
	@$(call add,THE_PACKAGES,qt6-wayland)
	@$(call add,THE_PACKAGES,plasma5-discover)
ifneq (,$(filter-out e2k% riscv64 loongarch64,$(ARCH)))
	@$(call add,THE_PACKAGES,falkon-kde5)
endif

mixin/xfce-base: use/x11/xfce +nm-gtk \
	use/fonts/ttf/redhat use/fonts/ttf/google/extra
	@$(call add,THE_BRANDING,xfce-settings)
	@$(call add,THE_PACKAGES,xfce4-regular)
	@$(call add,THE_PACKAGES,xreader)
	@$(call add,THE_PACKAGES,xdg-user-dirs-gtk)
	@$(call add,THE_PACKAGES,xkill)

mixin/regular-xfce: mixin/xfce-base use/domain-client +pipewire
	@$(call add,THE_PACKAGES,pavucontrol xscreensaver-frontend)
	@$(call add,THE_PACKAGES,xfce4-pulseaudio-plugin xfce-polkit)

mixin/basko: mixin/xfce-base +net-eth \
	use/fonts/otf/adobe use/fonts/otf/mozilla
	@$(call add,THE_LISTS,basko)
	@$(call set,BRANDING,basko)

mixin/regular-lxde: use/x11/lxde use/im +nm-gtk
	@$(call add,THE_PACKAGES,qasmixer qpdfview)

mixin/regular-lxqt: use/x11/lxqt +nm-gtk; @:

mixin/mate-base: use/x11/mate use/fonts/ttf/google +nm-gtk
	@$(call add,THE_LISTS,$(call tags,mobile mate))

mixin/regular-mate: mixin/mate-base use/domain-client; @:
ifneq (,$(filter-out riscv64,$(ARCH)))
	@$(call add,THE_LISTS,$(call tags,base smartcard))
endif

mixin/office: use/fonts/ttf/google use/fonts/ttf/xo
	@$(call add,THE_LISTS,$(call tags,desktop && (cups || office)))
	@$(call add,THE_PACKAGES,apt-indicator)

# NB: never ever use/syslinux/ui/gfxboot here as gfxboot mangles
#     kernel cmdline resulting in method:disk instead of method:cdrom
#     which will change propagator's behaviour to probe additional
#     filesystems (ro but no loop) thus potentially writing to
#     an unrecovered filesystem's journal
mixin/regular-rescue: use/rescue use/isohybrid use/luks use/branding \
	use/syslinux/ui/menu use/syslinux/timeout/600 \
	use/rescue/.base use/syslinux/sdab.cfg use/grub/sdab_bios.cfg \
	use/firmware/qlogic test/rescue/no-x11 +sysvinit; @:

mixin/regular-builder: use/dev/builder/base use/net/dhcp use/ntp/chrony
	@$(call add,THE_PACKAGES,bash-completion elinks gpm lftp openssh)
	@$(call add,THE_PACKAGES,rpm-utils screen tmux wget zsh)
	@$(call add,THE_PACKAGES,apt-repo)

### vm.mk
mixin/cloud-init:
	@$(call add,BASE_PACKAGES,cloud-init)
	@$(call add,DEFAULT_SERVICES_ENABLE,cloud-config cloud-final)
	@$(call add,DEFAULT_SERVICES_ENABLE,cloud-init cloud-init-local)
	@$(call set,GLOBAL_NET_ETH,)

mixin/opennebula-context:
	@$(call add,BASE_PACKAGES,opennebula-context)
	@$(call add,DEFAULT_SERVICES_ENABLE,one-context-local one-context)

mixin/icewm: use/x11/lightdm/gtk +icewm; @:
