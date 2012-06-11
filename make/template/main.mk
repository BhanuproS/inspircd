#
# InspIRCd -- Internet Relay Chat Daemon
#
#   Copyright (C) 2009-2010 Daniel De Graaf <danieldg@inspircd.org>
#
# This file is part of InspIRCd.  InspIRCd is free software: you can
# redistribute it and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation, version 2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


#
#               InspIRCd Main Makefile
#
# This file is automagically generated by configure, from
# make/template/main.mk. Any changes made to the generated
#     files will go away whenever it is regenerated!
#
# Please do not edit unless you know what you're doing. This
# needs to work in both GNU and BSD make; it is mangled for
# them by configure.
#


CC = @CC@
SYSTEM = @SYSTEM@
BUILDPATH = @BUILD_DIR@
SOCKETENGINE = @SOCKETENGINE@
PURE_STATIC = @PURE_STATIC@
CXXFLAGS = -pipe -fPIC -DPIC -Iinclude
LDLIBS = -pthread -lstdc++
LDFLAGS = 
CORELDFLAGS = -rdynamic -L. $(LDFLAGS)
PICLDFLAGS = -fPIC -shared -rdynamic $(LDFLAGS)
BASE = @BASE_DIR@
CONPATH = @CONFIG_DIR@
MODPATH = @MODULE_DIR@
BINPATH = @BINARY_DIR@
INSTUID = @UID@
INSTMODE_DIR = 0755
INSTMODE_BIN = 0755
INSTMODE_LIB = 0644


@IFEQ $(CC) icc
  CXXFLAGS += -Wshadow
@ELSE
  CXXFLAGS += -pedantic -Woverloaded-virtual -Wshadow -Wformat=2 -Wmissing-format-attribute -Wall -Wextra -Wno-unused-parameter -Winit-self -Wfloat-equal -Wcast-qual -Wcast-align -Wpacked -Wredundant-decls -Wno-variadic-macros
@ENDIF


@IFEQ $(SYSTEM) linux
  LDLIBS += -ldl -lrt
@ENDIF
@IFEQ $(SYSTEM) gnukfreebsd
  LDLIBS += -ldl -lrt
@ENDIF
@IFEQ $(SYSTEM) openbsd
  LDLIBS += -Wl,--export-dynamic
@ENDIF
@IFEQ $(SYSTEM) gnu
  LDLIBS += -ldl -lrt
@ENDIF
@IFEQ $(SYSTEM) solaris
  LDLIBS += -lsocket -lnsl -lrt -lresolv
@ENDIF
@IFEQ $(SYSTEM) sunos
  LDLIBS += -lsocket -lnsl -lrt -lresolv
@ENDIF
@IFEQ $(SYSTEM) darwin
  CXXFLAGS += -DDARWIN -frtti
  LDLIBS += -ldl
  CORELDFLAGS = -dynamic -bind_at_load -L. $(LDFLAGS)
  PICLDFLAGS = -fPIC -shared -twolevel_namespace -undefined dynamic_lookup $(LDFLAGS)
@ENDIF
@IFEQ $(SYSTEM) interix
  CXXFLAGS += -D_ALL_SOURCE -I/usr/local/include
@ENDIF

@IFNDEF D
  D=0
@ENDIF

DBGOK=0
@IFEQ $(D) 0
  CXXFLAGS += -O2 -g1
  HEADER = std-header
  DBGOK=1
@ENDIF
@IFEQ $(D) 1
  CXXFLAGS += -O0 -g3 -Werror
  HEADER = debug-header
  DBGOK=1
@ENDIF
@IFEQ $(D) 2
  CXXFLAGS += -O2 -g3
  HEADER = debug-header
  DBGOK=1
@ENDIF

# Default target
TARGET = all
FOOTER = finishmessage

@IFDEF M
  HEADER = mod-header
  FOOTER = mod-footer
  @BSD_ONLY TARGET = modules/${M:S/.so$//}.so
  @GNU_ONLY TARGET = modules/$(M:.so=).so
@ENDIF

@IFDEF T
  HEADER =
  FOOTER = target
  TARGET = $(T)
@ENDIF

@GNU_ONLY MAKEFLAGS += --no-print-directory
@GNU_ONLY SOURCEPATH = $(shell /bin/pwd)
@BSD_ONLY SOURCEPATH != /bin/pwd

@IFDEF V
  RUNCC = $(CC)
  RUNLD = $(CC)
  VERBOSE = -v
  HEADER += print-vars
@ELSE
  @GNU_ONLY MAKEFLAGS += --silent
  @BSD_ONLY MAKE += -s
  RUNCC = perl $(SOURCEPATH)/make/run-cc.pl $(CC)
  RUNLD = perl $(SOURCEPATH)/make/run-cc.pl $(CC)
  VERBOSE =
@ENDIF

PSOK = 0
@IFEQ $(PURE_STATIC) 0
  PSOK = 1
@ENDIF
@IFEQ $(PURE_STATIC) 1
  CXXFLAGS += -DPURE_STATIC
  PSOK = 1
@ENDIF

@DO_EXPORT RUNCC RUNLD CXXFLAGS LDLIBS PICLDFLAGS VERBOSE SOCKETENGINE CORELDFLAGS
@DO_EXPORT SOURCEPATH BUILDPATH PURE_STATIC SPLIT_CC

# Default target
TARGET = all

@IFDEF M
    HEADER = mod-header
    FOOTER = mod-footer
    @BSD_ONLY TARGET = modules/${M:S/.so$//}.so
    @GNU_ONLY TARGET = modules/$(M:.so=).so
@ENDIF

@IFDEF T
    HEADER =
    FOOTER = target
    TARGET = $(T)
@ENDIF

@IFEQ $(DBGOK) 0
  HEADER = unknown-debug-level
@ENDIF
@IFEQ $(PSOK) 0
  HEADER = unknown-value-for-pure_static
@ENDIF

all: $(FOOTER)

target: $(HEADER) $(VERBOSE_HEADER)
	$(MAKEENV) perl make/calcdep.pl
	cd $(BUILDPATH); $(MAKEENV) $(MAKE) -f real.mk $(TARGET)

debug:
	@${MAKE} D=1 all

debug-header:
	@echo "*************************************"
	@echo "*    BUILDING WITH DEBUG SYMBOLS    *"
	@echo "*                                   *"
	@echo "*   This will take a *long* time.   *"
	@echo "*  Please be aware that this build  *"
	@echo "*  will consume a very large amount *"
	@echo "*  of disk space (~350MB), and may  *"
	@echo "*  run slower. Use the debug build  *"
	@echo "*  for module development or if you *"
	@echo "*    are experiencing problems.     *"
	@echo "*                                   *"
	@echo "*************************************"

mod-header:
@IFEQ $(PURE_STATIC) 1
	@echo 'Cannot build single modules in pure-static build'
	@exit 1
@ENDIF
	@echo 'Building single module:'

mod-footer: target
	@if [ '$(BUILDPATH)'/modules/ -ef '$(MODPATH)' ]; then \
		echo 'Build successful; load or reload the module to use'; \
	else \
		echo 'To install, copy $(BUILDPATH)/$(TARGET) to $(MODPATH)'; \
		echo 'Or, run "make install"'; \
	fi

std-header:
	@echo "*************************************"
	@echo "*       BUILDING INSPIRCD           *"
	@echo "*                                   *"
	@echo "*   This will take a *long* time.   *"
	@echo "*     Why not read our wiki at      *"
	@echo "*     http://wiki.inspircd.org      *"
	@echo "*  while you wait for make to run?  *"
	@echo "*************************************"

finishmessage: target
	@echo ""
	@echo "*************************************"
	@echo "*        BUILD COMPLETE!            *"
	@echo "*                                   *"
	@echo "*   To install InspIRCd, type:      *"
	@echo "*         make install              *"
	@echo "*************************************"

install: target
	@if [ "$(INSTUID)" = 0 -o "$(INSTUID)" = root ]; then \
		echo ""; \
		echo "Error: You must specify a non-root UID for the server"; \
		echo ""; \
		echo "If you are making a package, please specify using ./configure --uid"; \
		echo "Otherwise, rerun using 'make INSTUID=irc install', where 'irc' is the user"; \
		echo "who will be running the ircd. You will also need to modify the start script."; \
		echo ""; \
		exit 1; \
	fi
	@-install -d -o $(INSTUID) -m $(INSTMODE_DIR) '$(BASE)'
	@-install -d -o $(INSTUID) -m $(INSTMODE_DIR) '$(BASE)'/data
	@-install -d -o $(INSTUID) -m $(INSTMODE_DIR) '$(BASE)'/logs
	@-install -d -m $(INSTMODE_DIR) '$(BINPATH)'
	@-install -d -m $(INSTMODE_DIR) '$(CONPATH)/examples'
	@-install -d -m $(INSTMODE_DIR) '$(MODPATH)'
	[ '$(BUILDPATH)'/bin/ -ef '$(BINPATH)' ] || install -m $(INSTMODE_BIN) '$(BUILDPATH)'/bin/inspircd '$(BINPATH)'
@IFEQ $(PURE_STATIC) 0
	[ '$(BUILDPATH)'/modules/ -ef '$(MODPATH)' ] || install -m $(INSTMODE_LIB) '$(BUILDPATH)'/modules/*.so '$(MODPATH)'
@ENDIF
	-install -m $(INSTMODE_BIN) @STARTSCRIPT@ '$(BASE)' 2>/dev/null
	-install -m $(INSTMODE_LIB) tools/gdbargs '$(BASE)'/.gdbargs 2>/dev/null
	-install -m $(INSTMODE_LIB) docs/*.example '$(CONPATH)/examples'
	@echo ""
	@echo "*************************************"
	@echo "*        INSTALL COMPLETE!          *"
	@echo "*************************************"
	@echo 'Paths:'
	@echo '  Base install: $(BASE)'
	@echo '  Configuration: $(CONPATH)'
	@echo '  Binaries: $(BINPATH)'
	@echo '  Modules: $(MODPATH)'
	@echo 'To start the ircd, run: $(BASE)/inspircd start'
	@echo 'Remember to create your config file:' $(CONPATH)/inspircd.conf
	@echo 'Examples are available at:' $(CONPATH)/examples/


@GNU_ONLY RCS_FILES = $(wildcard .git/index src/version.sh)
@BSD_ONLY RCS_FILES = src/version.sh
GNUmakefile BSDmakefile: make/template/main.mk configure $(RCS_FILES)
	./configure -update
@BSD_ONLY .MAKEFILEDEPS: BSDmakefile

clean:
	@echo Cleaning...
	-rm -f $(BUILDPATH)/bin/inspircd $(BUILDPATH)/include $(BUILDPATH)/real.mk
	-rm -rf $(BUILDPATH)/obj $(BUILDPATH)/modules
	@-rmdir $(BUILDPATH)/bin 2>/dev/null
	@-rmdir $(BUILDPATH) 2>/dev/null
	@echo Completed.

deinstall:
	-rm $(BINPATH)/inspircd
	-rm $(MODPATH)/*.so
	@echo Configuration files and logs in ${BASE} were not removed

configureclean:
	rm -f .config.cache
	rm -f src/modules/Makefile
	rm -f src/commands/Makefile
	rm -f src/Makefile
	-rm -f Makefile
	rm -f BSDmakefile
	rm -f GNUmakefile
	rm -f include/inspircd_config.h
	rm -f include/inspircd_version.h

distclean: clean configureclean

print-vars:
	@echo 'Global settings:'
	@echo ' SYSTEM = ${SYSTEM}'
	@echo ' SOCKETENGINE = ${SOCKETENGINE}'
	@echo ' PURE_STATIC = ${PURE_STATIC}'
	@echo ' SPLIT_CC = ${SPLIT_CC}'
	@echo ' TARGET = ${TARGET}'
	@echo ' HEADER = ${HEADER}'
	@echo ' FOOTER = ${FOOTER}'
	@echo 'Compilation settings:'
	@echo ' CC = ${CC}'
	@echo ' RUNCC = ${RUNCC}'
	@echo ' RUNLD = ${RUNLD}'
	@echo ' CXXFLAGS = ${CXXFLAGS}'
	@echo ' LDFLAGS = ${LDFLAGS}'
	@echo ' LDLIBS = ${LDLIBS}'
	@echo ' PICLDFLAGS = ${PICLDFLAGS}'
	@echo ' CORELDFLAGS = ${CORELDFLAGS}'
	@echo 'Paths:'
	@echo ' SOURCEPATH = ${SOURCEPATH}'
	@echo ' BUILDPATH = ${BUILDPATH}'
	@echo ' BASE = ${BASE}'
	@echo ' CONPATH = ${CONPATH}'
	@echo ' MODPATH = ${MODPATH}'
	@echo ' BINPATH = ${BINPATH}'
	@echo 'Install:'
	@echo ' INSTUID = ${INSTUID}'
	@echo ' INSTMODE DIR/BIN/LIB = ${INSTMODE_DIR}/${INSTMODE_BIN}/${INSTMODE_LIB}'

help:
	@echo 'InspIRCd Makefile'
	@echo ''
	@echo 'Use: ${MAKE} [flags] [targets]'
	@echo ''
	@echo 'Flags:'
	@echo ' V=1       Show the full command being executed instead of "BUILD: dns.cpp"'
	@echo ' D=1       Enable debug build, for module development or crash tracing'
	@echo ' -j <N>    Run a parallel build using N jobs'
	@echo ' VAR=VALUE Override a Makefile setting; see "make print-vars" for values'
	@echo ''
	@echo 'User targets:'
	@echo ' all       Complete build of InspIRCd, without installing'
	@echo ' install   Build and install InspIRCd to the directory chosen in ./configure'
	@echo '           Currently installs to ${BASE}'
	@echo ' debug     Compile a debug build. Equivalent to "make D=1 all"'
	@echo ' docs      Create developer documentation in dev-docs'
	@echo ''
	@echo ' M=m_foo   Builds a single module (cmd_foo also works here)'
	@echo ' T=target  Builds a user-specified target, such as "inspircd" or "modules"'
	@echo '           Other targets are specified by their path in the build directory'
	@echo '           Multiple targets may be separated by a space'
	@echo ''
	@echo ' clean     Cleans object files produced by the compile'
	@echo ' distclean Cleans all files produced by compile and ./configure'
	@echo '           Note: this includes the Makefile'
	@echo ' deinstall Removes the files created by "make install"'
	@echo

docs:
	doxygen docs/Doxyfile

.PHONY: all target debug debug-header mod-header mod-footer std-header finishmessage install clean deinstall configureclean print-vars help docs
