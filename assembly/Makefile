MVN ?= mvn
MVN_LOG ?= cat
DOCKER := docker

.PHONY : default
ifeq ($(shell uname), Darwin)
default : dmg
else
default : zip-linux
endif

.PHONY : help
help :
	echo "make [default]:"                                                      >&2
	echo "	Builds the default package for the current platform"                >&2
	echo "make dmg:"                                                            >&2
	echo "	Builds a DMG image (Mac OS disk image)"                             >&2
	echo "make exe:"                                                            >&2
	echo "	Builds a EXE (Windows installer)"                                   >&2
	echo "make deb:"                                                            >&2
	echo "	Builds a DEB (Debian package)"                                      >&2
	echo "make rpm:"                                                            >&2
	echo "	Builds a RPM (RedHat package)"                                      >&2
	echo "make zip-linux:"                                                      >&2
	echo "	Builds a ZIP for Linux"                                             >&2
	echo "make all:"                                                            >&2
	echo "	Builds a DMG, a EXE, a DEB, a RPM and a ZIP for Linux"              >&2
	echo "make zip-mac:"                                                        >&2
	echo "	Builds a ZIP for Mac OS"                                            >&2
	echo "make zip-win:"                                                        >&2
	echo "	Builds a ZIP for Windows"                                           >&2
	echo "make zips:"                                                           >&2
	echo "	Builds a ZIP for each platform"                                     >&2
	echo "make zip-minimal:"                                                    >&2
	echo "	Builds a minimal ZIP that will complete itself upon first update"   >&2
	echo "make docker:"                                                         >&2
	echo "	Builds a Docker image"                                              >&2
	echo "make check|check-docker:"                                             >&2
	echo "	Tests the Docker image"                                             >&2

assembly/VERSION     := 1.11.2-SNAPSHOT
assembly/BASEDIR     := .
MVN_LOCAL_REPOSITORY ?= $(HOME)/.m2/repository

include deps.mk

.PHONY : all
all : dmg exe deb rpm zip-linux

.PHONY : zips
zips : zip-mac zip-linux zip-win

.PHONY : dmg exe deb rpm zip-linux zip-mac zip-win zip-minimal deb-cli rpm-cli

dmg         : $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).dmg
exe         : $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).exe
deb         : $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).deb
rpm         : $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).rpm
zip-linux   : $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-linux.zip
zip-mac     : $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-mac.zip
zip-win     : $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-win.zip
zip-minimal : $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-minimal.zip
deb-cli     : $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-cli.deb
rpm-cli     : $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-cli.rpm

$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).exe         : mvn -Punpack-cli-win \
                                                                                                                       -Punpack-updater-win \
                                                                                                                       -Punpack-updater-gui-win \
                                                                                                                       -Passemble-win-dir \
                                                                                                                       -Ppackage-exe
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).deb         : mvn -Punpack-updater-linux \
                                                                                                                       -Ppackage-deb
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-linux.zip   : mvn -Punpack-cli-linux \
                                                                                                                       -Punpack-updater-linux \
                                                                                                                       -Passemble-linux-zip
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-mac.zip     : mvn -Punpack-cli-mac \
                                                                                                                       -Punpack-updater-mac \
                                                                                                                       -Passemble-mac-zip
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-win.zip     : mvn -Punpack-cli-win \
                                                                                                                       -Punpack-updater-win \
                                                                                                                       -Punpack-updater-gui-win \
                                                                                                                       -Passemble-win-zip
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-minimal.zip : mvn -Punpack-updater-mac \
                                                                                                                       -Punpack-updater-linux \
                                                                                                                       -Punpack-updater-win \
                                                                                                                       -Passemble-minimal-zip
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-cli.deb     : mvn -Punpack-cli-linux \
                                                                                                                       -Ppackage-deb-cli
ifeq ($(shell uname), Darwin)
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).dmg         : mvn -Punpack-cli-mac \
                                                                                                                       -Punpack-updater-mac \
                                                                                                                       -Passemble-mac-dir \
                                                                                                                       -Ppackage-dmg
	test -e $@
else
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).dmg         :
	@echo "Can not build DMG because not running MacOS" >&2
	exit 1
endif
ifeq ($(shell test -f /etc/redhat-release; echo $$?), 0)
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).rpm         : mvn -Passemble-linux-dir \
                                                                                                                       -Ppackage-rpm
	test -e $@
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-cli.rpm     : mvn -Punpack-cli-linux \
                                                                                                                       -Ppackage-rpm-cli
	test -e $@
else
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).rpm \
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-cli.rpm :
	@echo "Can not build RPM because not running RedHat/CentOS" >&2
	exit 1
endif

.PHONY : docker
docker : target/assembly-$(assembly/VERSION)-linux/daisy-pipeline/bin/pipeline2
	cp Dockerfile.without_builder target/assembly-$(assembly/VERSION)-linux/Dockerfile
	cd target/assembly-$(assembly/VERSION)-linux && \
	$(DOCKER) build -t daisyorg/pipeline-assembly .

.PHONY : dev-launcher
ifeq ($(shell uname), Darwin)
dev-launcher : target/assembly-$(assembly/VERSION)-mac/daisy-pipeline/bin/pipeline2
else
dev-launcher : target/assembly-$(assembly/VERSION)-linux/daisy-pipeline/bin/pipeline2
endif

target/assembly-$(assembly/VERSION)-mac/daisy-pipeline/bin/pipeline2   : mvn -Punpack-cli-mac \
                                                                             -Punpack-updater-mac \
                                                                             -Passemble-mac-dir
target/assembly-$(assembly/VERSION)-linux/daisy-pipeline/bin/pipeline2 : mvn -Punpack-cli-linux \
                                                                             -Punpack-updater-linux \
                                                                             -Passemble-linux-dir

$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).exe \
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).deb \
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-linux.zip \
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-mac.zip \
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-win.zip \
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-minimal.zip \
$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-cli.deb \
target/assembly-$(assembly/VERSION)-mac/daisy-pipeline/bin/pipeline2 \
target/assembly-$(assembly/VERSION)-linux/daisy-pipeline/bin/pipeline2 :
	test -e $@

.PHONY : check
check : check-docker

.PHONY : check-docker
check-docker :
	bash src/test/resources/test-docker-image.sh

#                          generate-resources      process-resources      prepare-package       package
#                          ---------------         -----------------      ---------------       -------
# unpack-cli-mac           unpack-cli-mac
# unpack-cli-linux         unpack-cli-linux
# unpack-cli-win           unpack-cli-win
# unpack-updater-mac       unpack-updater-mac
# unpack-updater-linux     unpack-updater-linux
# unpack-updater-win       unpack-updater-win
# unpack-updater-gui-win   unpack-updater-gui-win
# assemble-mac-dir                                                        assemble-mac-dir
# assemble-linux-dir                                                      assemble-linux-dir
# assemble-win-dir                                                        assemble-win-dir
# assemble-mac-zip                                                                              assemble-mac-zip
# assemble-linux-zip                                                                            assemble-linux-zip
# assemble-win-zip                                                                              assemble-win-zip
# assemble-minimal-zip                                                                          assemble-minimal-zip
# package-dmg                                                             install-node          javapackager
#                                                                         install-appdmg        package-appdmg
#                                                                         parse-version         attach-dmg
# package-exe                                                             copy-nsis-resources   package-exe
# package-deb                                      filter-deb-resources                         package-deb
# package-deb-cli                                                                               package-deb-cli
# package-rpm                                                                                   package-rpm
# package-rpm-cli                                                                               package-rpm-cli
# dev-launcher             generate-fileinstall-cfg-files                 assemble-dev-dir

PROFILES :=                 \
	assemble-linux-dir      \
	assemble-linux-zip      \
	assemble-mac-dir        \
	assemble-mac-zip        \
	assemble-win-dir        \
	assemble-win-zip        \
	assemble-minimal-zip    \
	package-deb             \
	package-deb-cli         \
	package-dmg             \
	package-exe             \
	package-rpm             \
	package-rpm-cli         \
	unpack-cli-linux        \
	unpack-cli-mac          \
	unpack-cli-win          \
	unpack-updater-linux    \
	unpack-updater-mac      \
	unpack-updater-win      \
	unpack-updater-gui-win  \
	dev-launcher

.PHONY : mvn
mvn :
ifndef DUMP_PROFILES
	$(MVN) clean install $(shell $(MAKE) -qs DUMP_PROFILES=true $(MAKECMDGOALS)) | $(MVN_LOG)
endif

.PHONY : $(addprefix -P,$(PROFILES))
ifdef DUMP_PROFILES
$(addprefix -P,$(PROFILES)) :
	+echo $@
endif
