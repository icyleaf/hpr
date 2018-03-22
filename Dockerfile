FROM icyleafcn/crystal:latest

COPY ./script/docker-entrypoint.sh /entrypoint.sh

ADD . /app
WORKDIR /app

RUN shards build --production && \
    chmod 755 /entrypoint.sh && \
    rm -rf /var/lib/apt/lists/*

VOLUME ["/app/config", "/app/repositories"]

EXPOSE 8848/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["hpr:init"]
