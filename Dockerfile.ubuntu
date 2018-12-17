FROM crystallang/crystal:0.27.0 as builder

RUN set -ex && \
    apt-get update -qqy && \
    apt-get install -y libsqlite3-dev

COPY . /app
WORKDIR /app

RUN shards build && \
    for f in `ls bin`; do ldd bin/$f | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%'; done

FROM icyleafcn/s6-overlay:ubuntu

WORKDIR /app

RUN set -ex && \
    apt-get update -qqy && \
    apt-get install -y --no-install-recommends openssh-client redis-server git libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/bin/ /bin/
COPY --from=builder /app/deps /
COPY docker/root /

VOLUME ["/app"]

EXPOSE 8848 6379
