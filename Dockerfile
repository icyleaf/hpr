FROM icyleafcn/crystal:latest

ADD . /app
WORKDIR /app

RUN shards build --production && \
    mv ./bin/hpr / && \
    mkdir -p /app/repositories && \
    rm -rf src lib bin .shards shard.lock shard.yml spec && \
    ssh-keygen -q -t rsa -N "" -f /root/.ssh/id_rsa -C "hpr in docker" && \
    SSH_PUBLIE_KEY=`cat /root/.ssh/id_rsa.pub` && \
    echo "\n\nGENERATED SSH PUBLIC KEY:\n##################################################################" && \
    echo "${SSH_PUBLIE_KEY}" && \
    echo "##################################################################\n\n"

VOLUME "/app/config"
VOLUME "/app/repositories"

# ENTRYPOINT ["/hpr"]
CMD ["/hpr", "-s"]
