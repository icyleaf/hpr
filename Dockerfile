FROM icyleafcn/crystal:latest

ADD . /app
WORKDIR /app

RUN shards build --production && \
    mv ./bin/hpr / && \
    mkdir -p /app/repositories && \
    rm -rf src lib bin .shards shard.lock shard.yml spec

VOLUME ["/app/repositories"]

CMD ["/hpr"]
