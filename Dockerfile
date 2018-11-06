FROM icyleafcn/crystal:0.26.1 as builder

ADD . /app
WORKDIR /app

RUN set -ex && \
    apk add --update --no-cache build-base openssl-dev yaml-dev && \
    shards build --production && \
    for f in `ls bin`; do ldd bin/$f | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%'; done

FROM icyleafcn/s6-overlay

COPY --from=builder /app/deps /
COPY --from=builder /app/bin/ /bin/
COPY --from=builder /app/docker/root /

WORKDIR /app

RUN apk add --update --no-cache openssh-client openssh-keygen git bash redis

VOLUME ["/app", "/data"]

EXPOSE 8848 6379
