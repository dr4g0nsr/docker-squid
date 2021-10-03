if [[ ! -z ${TRAFFIC_LIMIT} ]]; then
  echo "Traffic limit set for SQUID (trickle)"
  
#  TRAFFIC_DOWNLOAD_UPLOAD
  SQUID_EXEC="trickle -d 1000 -u 1000 squid"
fi
