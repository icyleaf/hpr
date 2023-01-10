FROM ruby:3.2-alpine
LABEL maintainer="icyleaf <icyleaf.cn@gmail.com>"

ENV S6_OVERLAY_VERSION=2.2.0.3

RUN set -ex && \
    apk add --update --no-cache curl && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | tar xfz - -C / && \
    apk del --no-cache curl && \
    apk add --no-cache build-base sqlite-dev openssh-client openssh-keygen git bash redis

WORKDIR /app

COPY Gemfile* /app/

RUN bundle install --binstubs --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3 --without development test

ENV HPR_ENV=production \
    HPR_RUNNING=docker

COPY . /app
COPY docker/root /

VOLUME /app

EXPOSE 8848 6379

ENTRYPOINT [ "/init" ]
