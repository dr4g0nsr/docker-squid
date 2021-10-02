#!/bin/bash
set -e

SQUID_EXEC="squid"

create_log_dir() {
  mkdir -p ${SQUID_LOG_DIR}
  chmod -R 755 ${SQUID_LOG_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR}
}

create_cache_dir() {
  mkdir -p ${SQUID_CACHE_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
}

if [[ -z ${CACHE_MANAGER} ]]; then
  echo "Enabling cache manager"
  nginx
fi

if [[ -z ${ELITE_PROXY} ]]; then
  echo "Elite proxy settings"
fi

if [[ -z ${TRAFFIC_LIMIT} ]]; then
  echo "Traffic limit set for SQUID (trickle)"
  SQUID_EXEC="trickle -d 1000 -u 1000 squid"
fi

create_log_dir
create_cache_dir

# default behaviour is to launch squid
if [[ -z ${1} ]]; then
  if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
    echo "Initializing cache..."
    $(which squid) -N -f /etc/squid/squid.conf -z
  fi
  echo "Starting squid..."
  exec ${SQUID_EXEC} -f /etc/squid/squid.conf -NYCd 1 ${EXTRA_ARGS}
  read -p "Press enter to continue"
else
  exec "$@"
  read -p "Press enter to continue"
fi
