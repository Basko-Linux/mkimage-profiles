# this makefile can be used standalone

# drop stock predefined rules
.DEFAULT:

SYMLINK = build

# tmpfs-sparing extra rule: cleanup workdir after completing each stage
# (as packed results are saved this only lowers RAM pressure)
# NB: it's useful enough to be enabled by default in DEBUG abscence
ifndef DEBUG
CLEAN ?= 1
endif
ifdef CLEAN
export GLOBAL_CLEAN_WORKDIR = clean-current
ifdef DEBUG
WARNING = (NB: DEBUG scope is limited when CLEAN is enabled)
endif
endif

# ordinary clean: destroys workdirs but not the corresponding results
clean:
	@find -name '*~' -delete >&/dev/null ||:
	@if [ -L "$(SYMLINK)" -a -d "$(SYMLINK)"/ ]; then \
		echo "$(TIME) cleaning up $(WARNING)"; \
		$(MAKE) -C "$(SYMLINK)" $@ \
			GLOBAL_BUILDDIR="$(realpath $(SYMLINK))" $(LOG) ||:; \
	fi

# there can be some sense in writing log here even if normally
# $(BUILDDIR)/ gets purged: make might have failed,
# and BUILDLOG can be specified by hand either
distclean: clean
	@if [ -L "$(SYMLINK)" -a -d "$(SYMLINK)"/ ]; then \
		build="$(realpath $(SYMLINK)/)"; \
		if [ "$$build" = / ]; then \
			echo "** ERROR: invalid \`"$(SYMLINK)"' symlink" >&2; \
			exit 128; \
		else \
			$(MAKE) -C "$(SYMLINK)" $@ \
				GLOBAL_BUILDDIR="$$build" $(LOG) ||: \
			rm -rf "$$build"; \
		fi; \
	fi
	@rm -f "$(SYMLINK)"

# builddir existing outside read-only metaprofile is less ephemeral
# than BUILDDIR is -- usually it's unneeded afterwards so just zap it
postclean: build-image
	@if [ "$(NUM_TARGETS)" -gt 1 -a -z "$(DEBUG)" ] || \
	    [ ! -L "$(SYMLINK)" -a "0$(DEBUG)" -lt 2 ]; then \
		echo "$(TIME) cleaning up after build"; \
		$(MAKE) -C "$(BUILDDIR)" distclean \
			GLOBAL_BUILDDIR="$(BUILDDIR)" $(LOG) ||:; \
		rm -rf "$(BUILDDIR)"; \
	fi
