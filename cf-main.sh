#!/usr/bin/env bash

# The URLs with the actual IP addresses used by CloudFlare
export CF_URL_IP4="https://www.cloudflare.com/ips-v4"
export CF_URL_IP6="https://www.cloudflare.com/ips-v6"

# Location of the configuration files
export CF_IP4="/opt/cloudflare-ips/ips-v4.txt"
export CF_IP6="/opt/cloudflare-ips/ips-v6.txt"

export CF_NGINX="/opt/cloudflare-ips/cf-nginx.conf"
export CF_NFTABLES="/opt/cloudflare-ips/cf-nftables.nft"
export CF_IPTABLES="/opt/cloudflare-ips/cf-iptables"
export CF_IP6TABLES="/opt/cloudflare-ips/cf-ip6tables"

# Temporary files
export CF_TEMP_IP4="/tmp/ips-v4.txt"
export CF_TEMP_IP6="/tmp/ips-v6.txt"

# We want to rebuild all configs on start anyway, so let's delete cached lists
test -f $CF_IP4 && rm $CF_IP4
test -f $CF_IP6 && rm $CF_IP6

while true
do
  echo "[$(date +%s.%N)] Checking for updated IPv4/v6 lists."
  if $(dirname "$0")/cf-update.sh; then
    echo $(date +%s) > /tmp/healthcheck
    echo "[$(date +%s.%N)] Task completed."
    sleep_time=$CF_INTERVAL
  else
    echo "[$(date +%s.%N)] Task failed."
    sleep_time=30
  fi

  # Remove the temporary files
  test -f $CF_TEMP_IP4 && rm $CF_TEMP_IP4
  test -f $CF_TEMP_IP6 && rm $CF_TEMP_IP6

  sleep $sleep_time
done

#killall -HUP nginx
