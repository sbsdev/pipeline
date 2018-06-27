#!/usr/bin/env bash

set -e
set -x

while test ${#} -gt 0; do
    case $1 in
        *)
            echo "Unsupported argument: $arg" >&2
            exit 1
            ;;
    esac
    shift
done

CURDIR=$(cd $(dirname $0) && pwd)

source $CURDIR/conf

# FIXME: make cross-platform
CLI_PLATFORM=darwin_386

# IMPORTANT: If you are using boot2docker make sure that port 8181 is forwarded.
# For example, if the machine is called "default":
# VBoxManage controlvm default natpf1 "tcp-port8181,tcp,127.0.0.1,8181,,8181"
# The alternative is to use the IP address of the boot2docker machine
# instead of "localhost".
WS_HOST=localhost
# WS_HOST=$(docker-machine ip default)
WS_PORT=8181

test ! -e $CURDIR/cli
test ! -e $CURDIR/debs
test ! -e $CURDIR/tmp

# Fetch assembly and mod-sbs debs from Maven
cd $CURDIR
mkdir -p debs
eval mvn $MVN_OPTS \
         org.apache.maven.plugins:maven-dependency-plugin:3.0.0:copy \
         -Dartifact=org.daisy.pipeline:assembly:$ASSEMBLY_VERSION:deb:all \
         -DoutputDirectory=debs
eval mvn $MVN_OPTS \
         org.apache.maven.plugins:maven-dependency-plugin:3.0.0:copy \
         -Dartifact=org.daisy.pipeline.modules.braille:mod-sbs:$MOD_SBS_VERSION:deb:all \
         -DoutputDirectory=debs

# Build docker image with these debs
cd $CURDIR
docker build .
IMAGE_ID=$(docker build . | tail -n 1 | sed 's/.* //')
rm -r debs

# Launch pipeline in container and wait for the web service it to be up
function pipeline_launch {
    echo "Launching pipeline" >&2
    CONTAINER_ID=$(docker run -d -p 0.0.0.0:$WS_PORT:8181 $IMAGE_ID)
    sleep 5
    while ! curl $WS_HOST:$WS_PORT/ws/alive >/dev/null 2>/dev/null; do
        echo "Waiting for web service to be up..." >&2
        sleep 2
    done
}

# Shutdown pipeline and remove container
function pipeline_shutdown {
    echo "Shutting down pipeline" >&2
    docker stop $CONTAINER_ID
    docker rm $CONTAINER_ID
}

# Fetch the cli from Maven
cd $CURDIR
test ! -e cli
mkdir -p cli && cd $_
eval mvn $MVN_OPTS \
         org.apache.maven.plugins:maven-dependency-plugin:3.0.0:copy \
         -Dartifact=org.daisy.pipeline:cli:$CLI_VERSION:zip:$CLI_PLATFORM \
         -DoutputDirectory=.
unzip cli-$CLI_VERSION-$CLI_PLATFORM.zip
echo "client_key: clientid" >> config.yml
echo "client_secret: supersecret" >> config.yml
CLI_PATH=$CURDIR/cli/dp2

function pipeline_lastid {
    $CLI_PATH --host http://$WS_HOST --port $WS_PORT \
              jobs 2>&1 | tail -n 1 | awk '{print $1}'
}

function pipeline_status {
    local JOB_ID=$(pipeline_lastid)
    if [ "$JOB_ID" = "" ]; then
        echo "failure"
    else
        local STATUS=$($CLI_PATH --host http://$WS_HOST --port $WS_PORT \
                                 status $JOB_ID 2>&1 | grep 'Status:' | awk '{print $2}')
        if [ "$STATUS" = "DONE" ]; then
            echo "success"
        elif [ "$STATUS" = "ERROR" ]; then
            echo "failure"
        else
            echo "error"
        fi
    fi
}

# Start timer
function timer_start {
    TIMER_NAME="$1"
    TIMER_START=$(date +"%s")
}

# End timer
function timer_end {
    local STATUS="$1"
    local TIMER_END=$(date +"%s")
    local TIMER=$(expr $TIMER_END - $TIMER_START)
    echo "$TIMER_NAME: ${TIMER}s ($STATUS)"
}

# Run the test on all files inside folder dtbooks
cd $CURDIR
mkdir tmp
EXIT_VALUE=0
find dtbooks -name '*.xml' | while read BOOK; do
    BOOK_ZIPPED="tmp/$(basename $BOOK).zip"
    zip -r "$BOOK_ZIPPED" "$BOOK"
    pipeline_launch
    timer_start "$BOOK (filesize: $(ls -lh $BOOK | awk '{print $5}'))"
    $CLI_PATH --host http://$WS_HOST --port $WS_PORT \
              sbs:dtbook-to-pef --data "$BOOK_ZIPPED" --persistent --source "$BOOK" --output tmp
    sleep 1 # why is this needed?
    STATUS="$(pipeline_status)"
    timer_end "$STATUS"
    if [ "$STATUS" != "success" ]; then
        EXIT_VALUE=1
    fi
    pipeline_shutdown
    break
done

# Cleanup
cd $CURDIR
rm -r cli
rm -r tmp

# Remove docker image
# docker rmi $IMAGE_ID

exit $EXIT_VALUE
