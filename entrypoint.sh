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

if [[ ! -z ${CACHE_MANAGER} ]]; then
  echo "Enabling cache manager: starting nginx and fcgiwrap"
  nginx > /dev/null 2>&1
  /etc/init.d/fcgiwrap start > /dev/null 2>&1
fi

if [[ ! -z SQUID_LIMIT ]]; then
  echo "Set squid limit (pool)"
  SQUID_PARTS=($SQUID_DOWNLOAD_UPLOAD)
  #echo "Traffic limit set for SQUID (trickle) DL ${SQUID_PARTS[0]} KB/sec / UL ${SQUID_PARTS[1]} KB/sec"
  #cp /etc/squid/squid.conf /etc/squid/squid.conf.backup
  #sed -i "s=#include /etc/squid/squid-delaypools.conf=include /etc/squid/squid-delaypools.conf=g" /etc/squid/squid.conf.backup
  #cat /etc/squid/squid.conf.backup > /etc/squid/squid.conf
else
  echo "No squid limits"
  #cp /etc/squid/squid.conf /etc/squid/squid.conf.backup
  #sed -i "s=include /etc/squid/squid-delaypools.conf=#include /etc/squid/squid-delaypools.conf=g" /etc/squid/squid.conf.backup
  #cat /etc/squid/squid.conf.backup > /etc/squid/squid.conf
fi

if [[ ! -z ${ELITE_PROXY} ]]; then
  echo "Elite proxy settings"
  #cp /etc/squid/squid.conf /etc/squid/squid.conf.backup
  #sed -i "s=include /etc/squid/squid-anonymous.conf=#include /etc/squid/squid-anonymous.conf=g" /etc/squid/squid.conf.backup
  #cat /etc/squid/squid.conf.backup > /etc/squid/squid.conf
else
  echo "Standard proxy"
  #cp /etc/squid/squid.conf /etc/squid/squid.conf.backup
  #sed -i "s=include /etc/squid/squid-anonymous.conf=#include /etc/squid/squid-anonymous.conf=g" /etc/squid/squid.conf.backup
  #cat /etc/squid/squid.conf.backup > /etc/squid/squid.conf
fi

if [[ ! -z ${TRAFFIC_LIMIT} ]]; then
  TRAFFIC_PARTS=($TRAFFIC_DOWNLOAD_UPLOAD)
  echo "Traffic limit set for SQUID (trickle) DL ${TRAFFIC_PARTS[0]} KB/sec / UL ${TRAFFIC_PARTS[1]} KB/sec"
  SQUID_EXEC="trickle -d ${TRAFFIC_PARTS[0]} -u ${TRAFFIC_PARTS[1]} squid"
else
  SQUID_EXEC="squid"
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
