FROM ruby:3.0-alpine
LABEL maintainer="icyleaf <icyleaf.cn@gmail.com>"

ARG S6_OVERLAY_VERSION=3.1.0.1

RUN set -ex && \
    apk add --no-cache build-base sqlite-dev openssh-client openssh-keygen git bash redis

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

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
