#!/usr/bin/env bash
set -e

[[ $DEBUG == true ]] && set -x

export HPR_SSH_PATH=/app/.ssh

cleanup_workspace() {
  mkdir -p /app/repositories
  mkdir -p /app/.ssh
}

generate_ssh_key() {
  if ! [ -f "${HPR_SSH_PATH}/id_rsa" ]; then
    echo "Generating public/private rsa key pair ..."
    ssh-keygen -q -t rsa -N "" -f "${HPR_SSH_PATH}/id_rsa" -C "hpr@docker"
  fi

  echo
  echo "SSH PUBLIC KEY:"
  echo "##################################################################"
  echo `cat ${HPR_SSH_PATH}/id_rsa.pub`
  echo "##################################################################"
  echo

  ln -sf ${HPR_SSH_PATH} /root/.ssh
}

config_ssh_config() {
  HPR_SSH_HOST=${HPR_SSH_HOST:-*}
  HPR_SSH_PORT=${HPR_SSH_PORT:-22}

  echo "Configuring ssh config ..."
  echo "Host ${HPR_SSH_HOST}" > ${HPR_SSH_PATH}/config
  echo "    HostName ${HPR_SSH_HOST}" >> ${HPR_SSH_PATH}/config
  echo "    Port ${HPR_SSH_PORT}" >> ${HPR_SSH_PATH}/config
  echo "    StrictHostKeyChecking no" >> ${HPR_SSH_PATH}/config
}

start_hpr_server() {
  echo "Starting hpr server ..."
  run_hpr --server
}

run_hpr() {
  hpr --file /app/config/hpr.json $@
}

run_hpr_migration() {
  hpr-migration --file /app/config/hpr.json $@
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
    run_hpr $@
    ;;
  hpr-migration)
    run_hpr_migration $@
    ;;
  *)
    exec "$@"
    ;;
esac
