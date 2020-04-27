#!/usr/bin/env bash

while true
do
  echo "[$(date +%s.%N)] Checking for updated IPv4/v6 lists."
  if $(dirname "$0")/cf-update.sh; then
    echo $(date +%s) > /tmp/healthcheck
    echo "[$(date +%s.%N)] Task completed."
  else
    echo "[$(date +%s.%N)] Task failed."
  fi
  sleep $CF_INTERVAL
done

#killall -HUP nginx
