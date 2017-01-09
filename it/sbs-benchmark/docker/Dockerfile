FROM openjdk:8

RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

# Install Pipeline through provided debs
COPY debs/ /root/debs/
WORKDIR /root
RUN DEBIAN_FRONTEND=noninteractive dpkg -i debs/*.deb

# Bind engine to 0.0.0.0 instead of localhost
RUN sed -i 's/org.daisy.pipeline.ws.host=.*/org.daisy.pipeline.ws.host=0.0.0.0/' /opt/daisy-pipeline2/etc/system.properties

# Remote mode
RUN echo REMOTE=true >> /etc/default/pipeline2d

EXPOSE 8181

CMD service pipeline2d start && tail -f /var/log/daisy-pipeline2/daisy-pipeline.log
