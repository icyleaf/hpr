#!/usr/bin/env sh
set -e

[[ $DEBUG == true ]] && set -x

cleanup_workspace() {
  mkdir -p /app/repositories
}

generate_ssh_key() {
  HPR_SSH_PATH=/root/.ssh/id_rsa

  if ! [ -f ${HPR_SSH_PATH} ]; then
    echo "Generating public/private rsa key pair ..."
    ssh-keygen -q -t rsa -N "" -f $HPR_SSH_PATH -C "hpr@docker"
  fi

  echo
  echo "GENERATED SSH PUBLIC KEY:"
  echo "##################################################################"
  echo `cat ${HPR_SSH_PATH}.pub`
  echo "##################################################################"
  echo
}

config_ssh_config() {
  echo "Configuring ssh config ..."

  HPR_SSH_HOST=${HPR_SSH_HOST:-*}
  HPR_SSH_PORT=${HPR_SSH_PORT:-22}

  echo "Host ${HPR_SSH_HOST}" > /root/.ssh/config
  echo "    HostName ${HPR_SSH_HOST}" >> /root/.ssh/config
  echo "    Port ${HPR_SSH_PORT}" >> /root/.ssh/config
  echo "    StrictHostKeyChecking no" >> /root/.ssh/config
}

start_hpr_server() {
  echo "Starting hpr server ..."
  /app/hpr --server
}

case ${1} in
  hpr:init|hpr:start)
    cleanup_workspace
    generate_ssh_key
    config_ssh_config
    start_hpr_server
    ;;
  hpr:server)
    start_hpr_server
    ;;
  hpr)
    /app/hpr $@
    ;;
  *)
    exec "$@"
    ;;
esac
