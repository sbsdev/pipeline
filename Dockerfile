# Build the sbs modules first
FROM maven:3.5-jdk-8 as builder

RUN apt-get update && apt-get install -y \
    libxml2-utils \
    make \
    pcregrep

ADD . /usr/src/pipeline2
WORKDIR /usr/src/pipeline2
RUN make dist-zip-linux

# then use the build artifacts to create an image where the pipeline is installed
FROM openjdk:8-jre
LABEL maintainer="Christian Egli <christian.egli@sbs.ch>"
COPY --from=builder /usr/src/pipeline2/assembly/target/pipeline2-*_linux/daisy-pipeline /opt/daisy-pipeline2
ENV PIPELINE2_WS_LOCALFS=false \
    PIPELINE2_WS_AUTHENTICATION=true \
    PIPELINE2_WS_AUTHENTICATION_CLIENTKEY=clientid \
    PIPELINE2_WS_AUTHENTICATION_CLIENTSECRET=sekret
EXPOSE 8181
ENTRYPOINT ["/opt/daisy-pipeline2/bin/pipeline2"]