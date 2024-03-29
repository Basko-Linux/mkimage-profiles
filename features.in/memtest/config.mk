ifeq (,$(filter-out i586 x86_64,$(ARCH)))
use/memtest: use/syslinux use/grub
	@$(call add_feature)
	@$(call add,SYSTEM_PACKAGES,memtest86+)
	@$(call add,SYSLINUX_CFG,memtest)
ifeq (,$(filter-out sisyphus p10,$(BRANCH)))
	@$(call add,GRUB_CFG,memtest)
else
	@$(call add,GRUB_CFG,memtest_bios)
endif
else
use/memtest: ; @:
endif
# see also use/efi/memtest86
