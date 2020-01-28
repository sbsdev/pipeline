.PHONY : default
default : help

.PHONY : all
all : check-sbs dist-deb

MVN_WORKSPACE           := .maven-workspace
MVN_CACHE               := .maven-cache

# -----------------------------------
TARGET_DIR              := .make-target
MVN_SETTINGS            := settings.xml
MVN_PROPERTIES          := -Dorg.ops4j.pax.url.mvn.localRepository="$(CURDIR)/$(MVN_WORKSPACE)" \
                           -Dorg.ops4j.pax.url.mvn.settings="$(CURDIR)/settings.xml"
MVN_RELEASE_CACHE_REPO  := $(MVN_CACHE)
GRADLE                  := gradle

ifneq ($(MAKECMDGOALS),)
ifneq ($(MAKECMDGOALS), help)
ifneq ($(MAKECMDGOALS), dump-maven-cmd)
ifneq ($(MAKECMDGOALS), dump-gradle-cmd)
include .make/main.mk
assembly/BASEDIR := assembly
include assembly/deps.mk
-include webui/.deps.mk
-include it/sbs-benchmark/.deps.mk
endif
endif
endif
endif

USER_HOME := $(shell echo ~)

# instead of passing system properties "workspace" and "cache" we substitute them in the settings.xml file
# this is required for org.ops4j.pax.url.mvn.settings
settings.xml : settings.xml.in
	cat $< | sed -e "s|\$${workspace}|$(CURDIR)/$(MVN_WORKSPACE)|g" \
	             -e "s|\$${cache}|$(CURDIR)/$(MVN_CACHE)|g" \
	             -e "s|\$${user\.home}|$(USER_HOME)|g" \
	             >$@

USER_HOME := $(shell echo ~)

# instead of passing system properties "workspace" and "cache" we substitute them in the settings.xml file
# this is required for org.ops4j.pax.url.mvn.settings
settings.xml : settings.xml.in
	cat $< | sed -e "s|\$${workspace}|$(CURDIR)/$(MVN_WORKSPACE)|g" \
	             -e "s|\$${cache}|$(CURDIR)/$(MVN_CACHE)|g" \
	             -e "s|\$${user\.home}|$(USER_HOME)|g" \
	             >$@

# -----------------------------------

.PHONY : dist
dist: dist-dmg dist-exe dist-zip-linux dist-zip-minimal dist-zip-win dist-zip-mac dist-deb dist-rpm dist-webui-deb dist-webui-rpm

.PHONY : dist-dmg
dist-dmg : pipeline2-$(assembly/VERSION)_mac.dmg

.PHONY : dist-exe
dist-exe : pipeline2-$(assembly/VERSION)_windows.exe

.PHONY : dist-zip-linux
dist-zip-linux : pipeline2-$(assembly/VERSION)_linux.zip

.PHONY : dist-zip-mac
dist-zip-mac : pipeline2-$(assembly/VERSION)_mac.zip

.PHONY : dist-zip-win
dist-zip-win : pipeline2-$(assembly/VERSION)_windows.zip

.PHONY : dist-zip-minimal
dist-zip-minimal : pipeline2-$(assembly/VERSION)_minimal.zip

.PHONY : dist-deb
dist-deb : pipeline2-$(assembly/VERSION)_debian.deb

.PHONY : dist-rpm
dist-rpm : pipeline2-$(assembly/VERSION)_redhat.rpm

.PHONY : dist-docker-image
dist-docker-image : assembly/.compile-dependencies
	unset MAKECMDGOALS && \
	$(MAKE) -C assembly docker

.PHONY : dist-webui-deb
dist-webui-deb : assembly/.compile-dependencies
	# see webui README for instructions on how to make a signed package for distribution
	cd webui && \
	./activator -Dmvn.settings.localRepository="file:$(CURDIR)/$(MVN_WORKSPACE)" clean debian:packageBin | $(MVN_LOG)
	mv webui/target/*deb .

.PHONY : dist-webui-rpm
dist-webui-rpm : assembly/.compile-dependencies
	# see webui README for instructions on how to make a signed package for distribution
	cd webui && \
	./activator -Dmvn.settings.localRepository="file:$(CURDIR)/$(MVN_WORKSPACE)" clean rpm:packageBin
	mv webui/target/rpm/RPMS/noarch/*.rpm .

ifeq ($(shell uname), Darwin)
dev_launcher := assembly/target/assembly-$(assembly/VERSION)-mac/daisy-pipeline/bin/pipeline2
dp2 := cli/build/bin/darwin_386/dp2
with-java-11 = JAVA_HOME=`/usr/libexec/java_home -v 11` $(1)
else
dev_launcher := assembly/target/assembly-$(assembly/VERSION)-linux/daisy-pipeline/bin/pipeline2
dp2 := cli/build/bin/linux_386/dp2
with-java-11 = $(1)
endif

.PHONY : dp2
dp2 : $(dp2)

.PHONY : run
run : $(dev_launcher)
	$(call with-java-11,$< shell)

.PHONY : run-gui
run-gui : $(dev_launcher)
	$(call with-java-11,$< gui shell)

.PHONY : run-cli
run-cli :
	echo "dp2 () { test -e $(dp2) || make $(dp2) && curl http://localhost:8181/ws/alive >/dev/null 2>/dev/null || make $(dev_launcher) && $(call with-java-11,$(dp2) --debug false --starting true --exec_line $(CURDIR)/$(dev_launcher) --ws_timeup 30 \"\$$@\"); }"
	echo '# Run this command to configure your shell: '
	echo '# eval $$(make $@)'

.PHONY : run-webui
run-webui : webui/.compile-dependencies
	if [ ! -d webui/dp2webui ]; then cp -r webui/dp2webui-cleandb webui/dp2webui ; fi
	cd webui && \
	./activator -Dmvn.settings.localRepository="file:$(CURDIR)/$(MVN_WORKSPACE)" run

.PHONY : run-docker
run-docker : dist-docker-image
	docker run --name pipeline --detach \
	       -e PIPELINE2_WS_HOST=0.0.0.0 \
	       -p 8181:8181 daisyorg/pipeline-assembly

.PHONY : check

.PHONY : check-sbs
check-sbs : check-sbs/braille check-sbs/braille-tables check-sbs/dtbook-to-odt

.PHONY : check-clientlib/go
check-clientlib/go :
	$(MAKE) -C clientlib/go check

.PHONY : release
release : assembly/.release

.PHONY : $(addprefix check-,$(MODULES) $(MAVEN_AGGREGATORS))
$(addprefix check-,$(MODULES) $(MAVEN_AGGREGATORS)) : check-% : %/.last-tested

pipeline2-$(assembly/VERSION)_mac.dmg \
	: $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).dmg \
	| .group-eval
	+$(EVAL) cp $< $@

pipeline2-$(assembly/VERSION)_windows.exe \
	: $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).exe \
	| .group-eval
	+$(EVAL) cp $< $@

pipeline2-$(assembly/VERSION)_linux.zip \
	: $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-linux.zip \
	| .group-eval
	+$(EVAL) cp $< $@

pipeline2-$(assembly/VERSION)_mac.zip \
	: $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-mac.zip \
	| .group-eval
	+$(EVAL) cp $< $@

pipeline2-$(assembly/VERSION)_windows.zip \
	: $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-win.zip \
	| .group-eval
	+$(EVAL) cp $< $@

pipeline2-$(assembly/VERSION)_minimal.zip \
	: $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION)-minimal.zip \
	| .group-eval
	+$(EVAL) cp $< $@

pipeline2-$(assembly/VERSION)_debian.deb \
	: $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).deb \
	| .group-eval
	+$(EVAL) cp $< $@

pipeline2-$(assembly/VERSION)_redhat.rpm \
	: $(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$(assembly/VERSION)/assembly-$(assembly/VERSION).rpm \
	| .group-eval
	+$(EVAL) cp $< $@

$(dev_launcher) : assembly/.compile-dependencies | .maven-init .group-eval
	+$(call eval-for-host-platform,./assembly-make.sh,dev-launcher)

.PHONY : benchmark
benchmark : it/sbs-benchmark/.dependencies
	MVN_OPTS="--settings '$(CURDIR)/settings.xml' -Dworkspace='$(CURDIR)/$(MVN_WORKSPACE)' -Dcache='$(CURDIR)/$(MVN_CACHE)'" \
	it/sbs-benchmark/run.sh --native

it/sbs-benchmark/.deps.mk : it/sbs-benchmark/conf
	while true; do \
		echo ".SECONDARY : it/sbs-benchmark/.dependencies" && \
		echo -n "it/sbs-benchmark/.dependencies :" && \
		source $< && \
		if [[ $$CLI_VERSION == *-SNAPSHOT ]]; then \
			echo " \\" && \
			if [ "$$(uname)" == Darwin ]; then \
				echo -n "	\$$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/cli/$$CLI_VERSION/cli-$$CLI_VERSION-darwin_386.zip"; \
			else \
				echo -n "	\$$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/cli/$$CLI_VERSION/cli-$$CLI_VERSION-linux_386.zip"; \
			fi; \
		fi && \
		if [[ $$ASSEMBLY_VERSION == *-SNAPSHOT ]]; then \
			echo " \\" && \
			if [ "$$(uname)" == Darwin ]; then \
				echo -n "	\$$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$$ASSEMBLY_VERSION/assembly-$$ASSEMBLY_VERSION-mac.zip"; \
			else \
				echo -n "	\$$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/assembly/$$ASSEMBLY_VERSION/assembly-$$ASSEMBLY_VERSION-linux.zip"; \
			fi; \
		fi && \
		echo "" && \
		break; \
	done >$@

.SECONDARY : assembly/.install.deb
assembly/.install.deb : assembly/.compile-dependencies | .maven-init .group-eval
	+$(call eval-for-host-platform,./assembly-make.sh,deb)

.SECONDARY : assembly/.install.rpm
assembly/.install.rpm : assembly/.compile-dependencies | .maven-init .group-eval
	+$(call eval-for-host-platform,./assembly-make.sh,rpm)

.SECONDARY : assembly/.install-linux.zip
assembly/.install-linux.zip : assembly/.compile-dependencies | .maven-init .group-eval
	+$(call eval-for-host-platform,./assembly-make.sh,zip-linux)

.SECONDARY : assembly/.install-minimal.zip
assembly/.install-minimal.zip : assembly/.compile-dependencies | .maven-init .group-eval
	+$(call eval-for-host-platform,./assembly-make.sh,zip-minimal)

.SECONDARY : assembly/.install-mac.zip
assembly/.install-mac.zip : assembly/.compile-dependencies | .maven-init .group-eval
	+$(call eval-for-host-platform,./assembly-make.sh,zip-mac)

.SECONDARY : assembly/.install-win.zip
assembly/.install-win.zip : assembly/.compile-dependencies | .maven-init .group-eval
	+$(call eval-for-host-platform,./assembly-make.sh,zip-win)

.SECONDARY : assembly/.install.dmg
assembly/.install.dmg : assembly/.compile-dependencies | .maven-init .group-eval
	+$(call eval-for-host-platform,./assembly-make.sh,dmg)

.SECONDARY : assembly/.install.exe
assembly/.install.exe : assembly/.compile-dependencies | .maven-init .group-eval
	+$(call eval-for-host-platform,./assembly-make.sh,exe)

webui/.deps.mk : webui/build.sbt
	if ! bash .make/make-webui-deps.mk.sh >$@; then \
		echo "\$$(error $@ could not be generated)" >$@; \
	fi

clean : clean-webui-deps
.PHONY : clean-webui-deps
clean-webui-deps :
	rm -f webui/.deps.mk

# FIXME: hard code dependency because unpack-cli-{mac,win,linux} are inside profiles
# assembly/.compile-dependencies : \
# 	$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/cli/2.1.2-SNAPSHOT/cli-2.1.2-SNAPSHOT-darwin_386.zip \
# 	$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/cli/2.1.2-SNAPSHOT/cli-2.1.2-SNAPSHOT-linux_386.zip \
# 	$(MVN_LOCAL_REPOSITORY)/org/daisy/pipeline/cli/2.1.2-SNAPSHOT/cli-2.1.2-SNAPSHOT-windows_386.zip

modules/sbs/braille/.install.deb : modules/sbs/braille/.install
modules/sbs/dtbook-to-odt/.install.deb : modules/sbs/dtbook-to-odt/.install

export PIPELINE_CLIENTLIB_PATH = $(CURDIR)/clientlib/go

cli/build/bin/darwin_386/dp2 cli/build/bin/linux_386/dp2 : cli/.install

cli/.install : cli/cli/*.go clientlib/go/*.go

.SECONDARY : cli/.install-darwin_386.zip cli/.install-linux_386.zip cli/.install-windows_386.zip
cli/.install-darwin_386.zip cli/.install-linux_386.zip cli/.install-windows_386.zip : cli/.install

updater/cli/.install : updater/cli/*.go

.SECONDARY : updater/cli/.install-darwin_386.zip updater/cli/.install-linux_386.zip updater/cli/.install-windows_386.zip
updater/cli/.install-darwin_386.zip updater/cli/.install-linux_386.zip updater/cli/.install-windows_386.zip : updater/cli/.install

.SECONDARY : libs/jstyleparser/.install-sources.jar
libs/jstyleparser/.install-sources.jar : libs/jstyleparser/.install

modules/scripts/dtbook-to-odt/.install-doc.jar : $(call rwildcard,modules/scripts/dtbook-to-odt/src/test/,*)

.SECONDARY : \
	modules/braille/liblouis-utils/liblouis-native/.install-mac.jar \
	modules/braille/liblouis-utils/liblouis-native/.install-linux.jar \
	modules/braille/liblouis-utils/liblouis-native/.install-windows.jar
modules/braille/liblouis-utils/liblouis-native/.install-mac.jar \
modules/braille/liblouis-utils/liblouis-native/.install-linux.jar \
modules/braille/liblouis-utils/liblouis-native/.install-windows.jar: \
	modules/braille/liblouis-utils/liblouis-native/.install

.SECONDARY : \
	modules/braille/libhyphen-utils/libhyphen-native/.install-mac.jar \
	modules/braille/libhyphen-utils/libhyphen-native/.install-linux.jar \
	modules/braille/libhyphen-utils/libhyphen-native/.install-windows.jar
modules/braille/libhyphen-utils/libhyphen-native/.install-mac.jar \
modules/braille/libhyphen-utils/libhyphen-native/.install-linux.jar \
modules/braille/libhyphen-utils/libhyphen-native/.install-windows.jar: \
	modules/braille/libhyphen-utils/libhyphen-native/.install

.maven-init : | $(MVN_WORKSPACE)
# the purpose of the test is for making "make -B" not affect this rule (to speed thing up)
$(MVN_WORKSPACE) :
	if ! [ -e $(MVN_WORKSPACE) ]; then \
		mkdir -p $(MVN_CACHE) && \
		cp -r $(MVN_CACHE) $@; \
	fi

.PHONY : cache
cache :
	if [ -e $(MVN_WORKSPACE) ]; then \
		echo "Caching downloaded artifacts..." >&2 && \
		rm -rf $(MVN_CACHE) && \
		rsync -mr --exclude "*-SNAPSHOT" --exclude "maven-metadata-*.xml" $(MVN_WORKSPACE)/ $(MVN_CACHE); \
	fi

clean : cache clean-workspace clean-old clean-dist clean-webui

.PHONY : clean-workspace
clean-workspace :
	rm -rf $(MVN_WORKSPACE)

.PHONY : clean-dist
clean-dist :
	rm -f *.zip *.deb *.rpm
	rm -rf webui/dp2webui

.PHONY : clean-webui
clean-webui :
	rm -f *.zip *.deb *.rpm
	rm -rf webui/dp2webui

# clean files generated by previous versions of this Makefile
.PHONY : clean-old
clean-old :
	rm -f .maven-modules
	rm -f .effective-pom.xml
	rm -f .gradle-pom.xml
	rm -f .maven-build.mk
	find . -name .deps.mk -exec rm -r "{}" \;
	find . -name .build.mk -exec rm -r "{}" \;
	find * -name .maven-to-install -exec rm -r "{}" \;
	find * -name .maven-to-test -exec rm -r "{}" \;
	find * -name .maven-to-test-dependents -exec rm -r "{}" \;
	find * -name .maven-snapshot-dependencies -exec rm -r "{}" \;
	find * -name .maven-effective-pom.xml -exec rm -r "{}" \;
	find * -name .maven-dependencies-to-install -exec rm -r "{}" \;
	find * -name .maven-dependencies-to-test -exec rm -r "{}" \;
	find * -name .maven-dependencies-to-test-dependents -exec rm -r "{}" \;
	find * -name .gradle-to-test -exec rm -r "{}" \;
	find * -name .gradle-snapshot-dependencies -exec rm -r "{}" \;
	find * -name .gradle-dependencies-to-install -exec rm -r "{}" \;
	find * -name .gradle-dependencies-to-test -exec rm -r "{}" \;

.PHONY : gradle-clean
gradle-clean :
	$(GRADLE) clean

TEMP_REPOS := modules/scripts/dtbook-to-daisy3/target/test/local-repo

.PHONY : go-offline
go-offline :
	if [ -e $(MVN_WORKSPACE) ]; then \
		for repo in $(TEMP_REPOS); do \
			if [ -e $$repo ]; then \
				rsync -mr --exclude "*-SNAPSHOT" --exclude "maven-metadata-*.xml" $$repo/ $(MVN_WORKSPACE); \
			fi \
		done \
	fi

.PHONY : checked
checked :
	touch $(addsuffix /.last-tested,$(MODULES))

.PHONY : dump-maven-cmd
dump-maven-cmd :
	echo "mvn () { $(shell dirname "$$(which mvn)")/mvn --settings \"$(CURDIR)/$(MVN_SETTINGS)\" $(MVN_PROPERTIES) \"\$$@\"; }"
	echo '# Run this command to configure your shell: '
	echo '# eval $$(make $@)'

.PHONY : dump-gradle-cmd
dump-gradle-cmd :
	echo M2_HOME=$(CURDIR)/$(SUPER_BUILD_SCRIPT_TARGET_DIR)/.gradle-settings $(GRADLE) $(MVN_PROPERTIES)

.PHONY : help
help :
	echo "make all:"                                                                                                >&2
	echo "	Incrementally compile and test code and package into a DMG, a EXE, a ZIP (for Linux), a DEB and a RPM"  >&2
	echo "make check:"                                                                                              >&2
	echo "	Incrementally compile and test code"                                                                    >&2
	echo "make dist:"                                                                                               >&2
	echo "	Incrementally compile code and package into a DMG, a EXE, a ZIP (for Linux), a DEB and a RPM"           >&2
	echo "make dist-dmg:"                                                                                           >&2
	echo "	Incrementally compile code and package into a DMG"                                                      >&2
	echo "make dist-exe:"                                                                                           >&2
	echo "	Incrementally compile code and package into a EXE"                                                      >&2
	echo "make dist-deb:"                                                                                           >&2
	echo "	Incrementally compile code and package into a DEB"                                                      >&2
	echo "make dist-rpm:"                                                                                           >&2
	echo "	Incrementally compile code and package into a RPM"                                                      >&2
	echo "make dist-zip-linux:"                                                                                     >&2
	echo "	Incrementally compile code and package into a ZIP for Linux"                                            >&2
	echo "make dist-zip-mac:"                                                                                       >&2
	echo "	Incrementally compile code and package into a ZIP for MacOS"                                            >&2
	echo "make dist-zip-win:"                                                                                       >&2
	echo "	Incrementally compile code and package into a ZIP for Windows"                                          >&2
	echo "make dist-docker-image:"                                                                                  >&2
	echo "	Incrementally compile code and package into a Docker image"                                             >&2
	echo "make dist-webui-deb:"                                                                                     >&2
	echo "	Compile Web UI and package into a DEB"                                                                  >&2
	echo "make dist-webui-rpm:"                                                                                     >&2
	echo "	Compile Web UI and package into a RPM"                                                                  >&2
	echo "make run:"                                                                                                >&2
	echo "	Incrementally compile code and run a server locally"                                                    >&2
	echo "make run-gui:"                                                                                            >&2
	echo "	Incrementally compile code and run the GUI locally"                                                     >&2
	echo "make run-webui:"                                                                                          >&2
	echo "	Compile and run web UI locally"                                                                         >&2
	echo "make run-cli:"                                                                                            >&2
	echo "	Get the command for compiling and running CLI locally"                                                  >&2
	echo "make run-docker:"                                                                                         >&2
	echo "	Incrementally compile code and run a server inside a Docker container"                                  >&2
	echo "make dump-maven-cmd:"                                                                                     >&2
	echo '	Get the Maven command used. To configure your shell: eval $$(make dump-maven-cmd)'                      >&2

ifndef VERBOSE
.SILENT:
endif
