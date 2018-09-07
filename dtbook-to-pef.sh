#!/usr/bin/env bash

set -x
set -e

# FIXME: this script could share some code with it/sbs-benchmark/run.sh and
# assembly/src/test/resources/test-docker-image.sh

DTBOOK=$1
shift
ARGS=$@

IMAGE=sbsdev/pipeline

# Pulls the image that was built on docker hub.
# In order to test local changes, you can instead run `make dist-docker-image` and then
# use the daisyorg/pipeline-assembly image.
docker pull $IMAGE:latest

CLIENTKEY=clientid
CLIENTSECRET=sekret
docker run \
       --name server \
       --detach \
       -e PIPELINE2_WS_HOST=0.0.0.0 \
       -e PIPELINE2_WS_AUTHENTICATION=true \
       -e PIPELINE2_WS_AUTHENTICATION_KEY=$CLIENTKEY \
       -e PIPELINE2_WS_AUTHENTICATION_SECRET=$CLIENTSECRET \
       -p 8181:8181 \
       $IMAGE

# wait for the server to start
sleep 5
tries=10
while ! curl localhost:8181/ws/alive >/dev/null 2>/dev/null; do
    if [[ $tries > 0 ]]; then
        echo "Waiting for web service to be up..." >&2
        sleep 2
        (( tries-- ))
    else
        exit 1
    fi
done

TEMP_DIR=$(mktemp -d $(pwd)/dtbook-to-pef_XXXXX)
cp $DTBOOK $TEMP_DIR
cd $TEMP_DIR
zip data.zip $(basename $DTBOOK)
if docker run \
          --name cli \
          --rm \
          -it \
          --link server \
          --entrypoint /opt/daisy-pipeline2/cli/dp2 \
          --volume="$(pwd):/mnt:rw" \
          $IMAGE \
          --host http://server \
          --starting false \
          --client_key $CLIENTKEY \
          --client_secret $CLIENTSECRET \
          sbs:dtbook-to-pef \
          --source $(basename $DTBOOK) \
          $ARGS \
          --output /mnt \
          --data /mnt/data.zip \
          --persistent
then
    :
else
    docker logs server > server.log 2> server.log
fi
open .
docker stop server
docker rm server

