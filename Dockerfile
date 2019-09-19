FROM alpine:latest
LABEL Description="Release tools" Vendor="Avto-Dev"

RUN set -x \
  && apk add --no-cache jq curl sed

COPY ./src/*.sh /bin/
