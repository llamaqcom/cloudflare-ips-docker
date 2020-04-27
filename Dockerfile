FROM debian:stable-slim
LABEL maintainer="docker@llamaq.com"

RUN apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
    gosu curl ca-certificates ipv6calc \
  && apt-get -y clean && apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

VOLUME /opt/cloudflare
ENV PUID=1000 PGID=1000 CF_INTERVAL=300

ADD VERSION .
COPY *.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1
CMD /usr/local/bin/entrypoint.sh
