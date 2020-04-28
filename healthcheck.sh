#!/bin/bash

if test -f /tmp/healthcheck; then
  if [[ $(echo "($(date +%s) - $(cat /tmp/healthcheck))" | bc -l) -lt $((CF_INTERVAL+60)) ]]; then
    exit 0
  fi
fi

exit 1
