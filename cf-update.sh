#!/usr/bin/env bash

## Partially based on Marek Bosman's script:
##  https://www.marekbosman.com/site/automatic-update-of-cloudflare-ip-addresses-in-nginx/

# Location of the nginx config file that contains the CloudFlare IP addresses.
CF_NGINX_CONFIG="/opt/cloudflare/nginx.conf"

# The URLs with the actual IP addresses used by CloudFlare.
CF_URL_IP4="https://www.cloudflare.com/ips-v4"
CF_URL_IP6="https://www.cloudflare.com/ips-v6"

# Temporary files
CF_NGINX_TEMP="/opt/cloudflare/nginx.tmp"
CF_TEMP_IP4="/opt/cloudflare/ips-v4.txt"
CF_TEMP_IP6="/opt/cloudflare/ips-v6.txt"

# Download ip lists or fail
curl --silent --show-error --output $CF_TEMP_IP4 $CF_URL_IP4 || exit 1
curl --silent --show-error --output $CF_TEMP_IP6 $CF_URL_IP6 || exit 1

# Sort ip lists (just in case some day cloudflare would rotate IPs and add comments or empty lines)
cat $CF_TEMP_IP4 | sed '/^[ \t]*#.*$/d' | sed -r '/^\s*$/d' | sort | tee $CF_TEMP_IP4 >/dev/null
cat $CF_TEMP_IP6 | sed '/^[ \t]*#.*$/d' | sed -r '/^\s*$/d' | sort | tee $CF_TEMP_IP6 >/dev/null

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

##
# Generate the new config file.
##

echo "# CloudFlare IP Ranges" > $CF_NGINX_TEMP
echo "" >> $CF_NGINX_TEMP

echo "# - IPv4 ($CF_URL_IP4)" >> $CF_NGINX_TEMP
while IFS='' read -r cidr; do
  echo "set_real_ip_from $cidr;" >> $CF_NGINX_TEMP
done < $CF_TEMP_IP4
echo "" >> $CF_NGINX_TEMP

echo "# - IPv6 ($CF_URL_IP6)" >> $CF_NGINX_TEMP
while IFS='' read -r cidr; do
  echo "set_real_ip_from $cidr;" >> $CF_NGINX_TEMP
done < $CF_TEMP_IP6
echo "" >> $CF_NGINX_TEMP

echo "real_ip_header CF-Connecting-IP;" >> $CF_NGINX_TEMP
echo "" >> $CF_NGINX_TEMP

##
# Check if configs are identical (i.e. to avoid trigger needless services restart)
##

if cmp --silent $CF_NGINX_TEMP $CF_NGINX_CONFIG; then
  echo "No updates."
else
  cp $CF_NGINX_TEMP $CF_NGINX_CONFIG
  echo "Update success."
fi

# Remove the temporary files.
rm $CF_TEMP_IP4 $CF_TEMP_IP6 $CF_NGINX_TEMP

exit 0
