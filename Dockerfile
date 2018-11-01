FROM icyleafcn/crystal:0.26.1 as builder

ADD . /app
WORKDIR /app

RUN set -ex && \
    apk add --update --no-cache build-base openssl-dev && \
    chmod +x docker-entrypoint.sh && \
    shards build --production && \
    for f in `ls bin`; do ldd bin/$f | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%'; done
    # ldd bin/hpr | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%' && \
    # ldd bin/hpr-migration | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%'

FROM icyleafcn/alpine:3.8

COPY --from=builder /app/deps /
COPY --from=builder /app/bin /usr/local/bin
COPY --from=builder /app/docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /app

RUN apk add --update --no-cache openssh-client openssh-keygen git bash openssl-dev

VOLUME ["/app"]

EXPOSE 8848

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["hpr:init"]
