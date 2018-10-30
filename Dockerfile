FROM icyleafcn/crystal:0.26.1 as builder

ADD . /app
WORKDIR /app

RUN set -ex && \
    apk add --update --no-cache build-base openssl-dev && \
    chmod +x docker-entrypoint.sh && \
    shards build --production && \
    ldd bin/hpr | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%'

FROM icyleafcn/alpine:3.8

COPY --from=builder /app/docker-entrypoint.sh /docker-entrypoint.sh
COPY --from=builder /app/bin/hpr /app/hpr
COPY --from=builder /app/deps /

WORKDIR /app

RUN apk add --update --no-cache openssh-client openssh-keygen git bash openssl-dev

VOLUME ["/app/config", "/app/repositories"]

EXPOSE 8848

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["hpr:init"]
