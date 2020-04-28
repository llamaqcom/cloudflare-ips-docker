#!/usr/bin/env bash

## Partially based on Marek Bosman's script:
##  https://www.marekbosman.com/site/automatic-update-of-cloudflare-ip-addresses-in-nginx/

# Download ip lists or fail
curl --silent --show-error --output $CF_TEMP_IP4 $CF_URL_IP4 || exit 1
curl --silent --show-error --output $CF_TEMP_IP6 $CF_URL_IP6 || exit 1

# Files should exist and be not empty (extra check)
test -s $CF_TEMP_IP4 || exit 1
test -s $CF_TEMP_IP6 || exit 1

# Sort ip lists (just in case some day cloudflare would rotate IPs and add comments or empty lines)
cat $CF_TEMP_IP4 | sed '/^[ \t]*#.*$/d' | sed -r '/^\s*$/d' | sort | tee $CF_TEMP_IP4 >/dev/null
cat $CF_TEMP_IP6 | sed '/^[ \t]*#.*$/d' | sed -r '/^\s*$/d' | sort | tee $CF_TEMP_IP6 >/dev/null

# Check if CloudFlare IP addresses have changed
if cmp --silent $CF_TEMP_IP4 $CF_IP4; then
  if cmp --silent $CF_TEMP_IP6 $CF_IP6; then
    echo "CloudFlare IP addresses have not changed."
    exit 0
  fi
fi

##
# Validate IPs
##

function isvalidip() {
  ipcalc "$1" | grep INVALID >/dev/null
  [[ $? -eq 0 ]] && return 1
  return 0
}

while IFS='' read -r cidr; do
  ipv6calc --quiet "$cidr" >/dev/null || exit 1
done < $CF_TEMP_IP4

while IFS='' read -r cidr; do
  ipv6calc --quiet "$cidr" >/dev/null || exit 1
done < $CF_TEMP_IP6

# Replace old CloudFlare IP addresses with new ones
cp $CF_TEMP_IP4 $CF_IP4
cp $CF_TEMP_IP6 $CF_IP6

##
# Generate the new config files for various services
##

# nginx
echo "# CloudFlare IP Ranges" > $CF_NGINX
echo "# Generated at $(date) by $0" >> $CF_NGINX
echo "" >> $CF_NGINX
awk '{ print "set_real_ip_from " $0 ";" }' $CF_IP4 >> $CF_NGINX
awk '{ print "set_real_ip_from " $0 ";" }' $CF_IP6 >> $CF_NGINX
echo "real_ip_header CF-Connecting-IP;" >> $CF_NGINX

# nftables
echo "# CloudFlare IP Ranges" > $CF_NFTABLES
echo "# Generated at $(date) by $0" >> $CF_NFTABLES
echo "" >> $CF_NFTABLES
awk '{ print "tcp dport https ip saddr " $0 " counter accept comment \"accept CloudFlare\"" }' $CF_IP4 >> $CF_NFTABLES
awk '{ print "tcp dport https ip saddr " $0 " counter accept comment \"accept CloudFlare\"" }' $CF_IP6 >> $CF_NFTABLES

echo "CloudFlare IP addresses updated successfully."
exit 0
