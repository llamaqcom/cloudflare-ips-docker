#!/bin/bash

set -eu

##
# Global Variables
##

## nothing

##
# Display Version
##

version=$(cat VERSION)
echo "Version: $version"

##
# Define user and group credentials used by worker processes
##

group=$(grep ":$PGID:" /etc/group | cut -d: -f1)

if [[ -z "$group" ]]; then
	group='cloudflare-rules'
	echo "Adding group $group($PGID)"
	addgroup --system --gid $PGID $group
fi

user=$(getent passwd $PUID | cut -d: -f1)

if [[ -z "$user" ]]; then
	user='cloudflare-rules'
	echo "Adding user $user($PUID)"
	adduser --system --disabled-login --gid $PGID --no-create-home --home /nonexistent --shell /bin/bash --uid $PUID $user
fi

echo "Credentials used by worker processes: user $user($PUID), group $group($PGID)."

##
# Setting Files & Directories
##

test -f /tmp/healthcheck && rm /tmp/healthcheck
chown $user:$group /opt/cloudflare-ips

##
# Start Main Loop
##

exec gosu $user:$group "/usr/local/bin/cf-main.sh"
