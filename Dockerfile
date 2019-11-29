# Build the sbs modules first
FROM maven:3.5-jdk-8 as builder

RUN apt-get update && apt-get install -y \
    libxml2-utils \
    make \
    golang \
    ruby-bundler \
    ruby-dev \
    zlib1g-dev

# taken from assembly/Makefile
# put before ADD to save space
RUN mkdir -p assembly/src/main/docker/
RUN curl -L -o assembly/src/main/docker/OpenJDK11-jdk_x64_linux_hotspot_11_28.tar.gz \
	"https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11%2B28/OpenJDK11-jdk_x64_linux_hotspot_11_28.tar.gz"

# taken from website/Makefile
# put before ADD to save time
# FIXME: this is brittle
RUN mkdir -p /usr/src/pipeline2/website && cd /usr/src/pipeline2/website && echo "source 'https://rubygems.org' do \n\
  ruby '>= 2.3.3' \n\
  gem 'jekyll', '3.3.0' \n\
  gem 'rdf', '1.1.15' \n\
  gem 'rdf-xsd', '1.1.4' \n\
  gem 'rdf-aggregate-repo', '1.1.0' \n\
  gem 'sparql-client', '1.1.6' \n\
  gem 'sparql', '1.1.8' \n\
  gem 'rdf-turtle', '1.1.7' \n\
  gem 'rdf-rdfa', '1.1.6' \n\
  gem 'commaparty', '0.0.2' \n\
  gem 'nokogiri', '1.8.4' \n\
  gem 'mustache', '1.0.2' \n\
  gem 'github-markup', '1.4.0' \n\
  gem 'coderay', '1.1.0' \n\
end" >Gemfile && echo "GEM \n\
  remote: https://rubygems.org/ \n\
  specs: \n\
    addressable (2.5.2) \n\
      public_suffix (>= 2.0.2, < 4.0) \n\
    builder (3.2.3) \n\
    coderay (1.1.0) \n\
    colorator (1.1.0) \n\
    commaparty (0.0.2) \n\
      nokogiri \n\
    ebnf (0.3.9) \n\
      rdf (~> 1.1) \n\
      sxp (~> 0.1, >= 0.1.3) \n\
    ffi (1.9.25) \n\
    forwardable-extended (2.6.0) \n\
    github-markup (1.4.0) \n\
    haml (4.0.7) \n\
      tilt \n\
    htmlentities (4.3.4) \n\
    jekyll (3.3.0) \n\
      addressable (~> 2.4) \n\
      colorator (~> 1.0) \n\
      jekyll-sass-converter (~> 1.0) \n\
      jekyll-watch (~> 1.1) \n\
      kramdown (~> 1.3) \n\
      liquid (~> 3.0) \n\
      mercenary (~> 0.3.3) \n\
      pathutil (~> 0.9) \n\
      rouge (~> 1.7) \n\
      safe_yaml (~> 1.0) \n\
    jekyll-sass-converter (1.5.2) \n\
      sass (~> 3.4) \n\
    jekyll-watch (1.5.1) \n\
      listen (~> 3.0) \n\
    kramdown (1.17.0) \n\
    link_header (0.0.8) \n\
    liquid (3.0.6) \n\
    listen (3.1.5) \n\
      rb-fsevent (~> 0.9, >= 0.9.4) \n\
      rb-inotify (~> 0.9, >= 0.9.7) \n\
      ruby_dep (~> 1.2) \n\
    mercenary (0.3.6) \n\
    mini_portile2 (2.3.0) \n\
    mustache (1.0.2) \n\
    net-http-persistent (2.9.4) \n\
    nokogiri (1.8.4) \n\
      mini_portile2 (~> 2.3.0) \n\
    pathutil (0.16.1) \n\
      forwardable-extended (~> 2.6) \n\
    public_suffix (3.0.3) \n\
    rb-fsevent (0.10.3) \n\
    rb-inotify (0.9.10) \n\
      ffi (>= 0.5.0, < 2) \n\
    rdf (1.1.15) \n\
      link_header (~> 0.0, >= 0.0.8) \n\
    rdf-aggregate-repo (1.1.0) \n\
      rdf (>= 1.1) \n\
    rdf-rdfa (1.1.6) \n\
      haml (~> 4.0) \n\
      htmlentities (~> 4.3) \n\
      rdf (~> 1.1, >= 1.1.6) \n\
      rdf-aggregate-repo (~> 1.1) \n\
      rdf-xsd (~> 1.1) \n\
    rdf-turtle (1.1.7) \n\
      ebnf (~> 0.3, >= 0.3.6) \n\
      rdf (~> 1.1, >= 1.1.10) \n\
    rdf-xsd (1.1.4) \n\
      rdf (~> 1.1, >= 1.1.9) \n\
    rouge (1.11.1) \n\
    ruby_dep (1.5.0) \n\
    safe_yaml (1.0.4) \n\
    sass (3.6.0) \n\
      sass-listen (~> 4.0.0) \n\
    sass-listen (4.0.0) \n\
      rb-fsevent (~> 0.9, >= 0.9.4) \n\
      rb-inotify (~> 0.9, >= 0.9.7) \n\
    sparql (1.1.8) \n\
      builder (~> 3.2) \n\
      ebnf (~> 0.3, >= 0.3.9) \n\
      rdf (~> 1.1, >= 1.1.13) \n\
      rdf-aggregate-repo (~> 1.1, >= 1.1.0) \n\
      rdf-xsd (~> 1.1) \n\
      sparql-client (~> 1.1) \n\
      sxp (~> 0.1) \n\
    sparql-client (1.1.6) \n\
      net-http-persistent (~> 2.9) \n\
      rdf (~> 1.1) \n\
    sxp (0.1.5) \n\
    tilt (2.0.8) \n\
\n\
PLATFORMS \n\
  ruby \n\
\n\
DEPENDENCIES \n\
  coderay (= 1.1.0)! \n\
  commaparty (= 0.0.2)! \n\
  github-markup (= 1.4.0)! \n\
  jekyll (= 3.3.0)! \n\
  mustache (= 1.0.2)! \n\
  nokogiri (= 1.8.4)! \n\
  rdf (= 1.1.15)! \n\
  rdf-aggregate-repo (= 1.1.0)! \n\
  rdf-rdfa (= 1.1.6)! \n\
  rdf-turtle (= 1.1.7)! \n\
  rdf-xsd (= 1.1.4)! \n\
  sparql (= 1.1.8)! \n\
  sparql-client (= 1.1.6)! \n\
\n\
RUBY VERSION \n\
   ruby 2.5.1p57 \n\
\n\
BUNDLED WITH \n\
   1.16.1" >Gemfile.lock && bundle install --path gems && rm Gemfile Gemfile.lock

ADD . /usr/src/pipeline2
WORKDIR /usr/src/pipeline2
RUN git checkout-index -af
RUN if ! make dist-zip-linux; then \
      if [ -e .make-target/commands ]; then \
        echo "cat .make-target/commands" && \
        cat .make-target/commands | sed 's/^/> /g'; \
      fi && \
      if [ -e maven.log ]; then \
        echo "cat maven.log" && \
        cat maven.log | sed 's/^/> /g'; \
      fi && \
      exit 1; \
    fi
RUN cd assembly/target && unzip assembly-*-linux.zip
# RUN make -C assembly src/main/docker/OpenJDK11-jdk_x64_linux_hotspot_11_28.tar.gz
RUN tar -zxvf assembly/src/main/docker/OpenJDK11-jdk_x64_linux_hotspot_11_28.tar.gz -C assembly/target/

# then use the build artifacts to create an image where the pipeline is installed
FROM debian:stretch
LABEL maintainer="Christian Egli <christian.egli@sbs.ch>"
COPY --from=builder /usr/src/pipeline2/assembly/target/daisy-pipeline /opt/daisy-pipeline2
COPY --from=builder /usr/src/pipeline2/assembly/target/jdk-11+28 /opt/jdk-11+28
ENV JAVA_HOME=/opt/jdk-11+28
ENV PIPELINE2_WS_LOCALFS=false \
    PIPELINE2_WS_AUTHENTICATION=true \
    PIPELINE2_WS_AUTHENTICATION_CLIENTKEY=clientid \
    PIPELINE2_WS_AUTHENTICATION_CLIENTSECRET=sekret
EXPOSE 8181
# for the healthcheck use PIPELINE2_HOST if defined. Otherwise use localhost
HEALTHCHECK --interval=30s --timeout=10s --start-period=1m CMD curl --fail http://${PIPELINE2_WS_HOST-localhost}:${PIPELINE2_WS_PORT:-8181}/${PIPELINE2_WS_PATH:-ws}/alive || exit 1
ENTRYPOINT ["/opt/daisy-pipeline2/bin/pipeline2"]
