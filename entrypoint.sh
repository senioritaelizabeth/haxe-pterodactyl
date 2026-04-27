#!/bin/sh
cd /home/container || exit 1
echo "Container ready"
printf '%s\n' "$STARTUP"
exec sh -c "$STARTUP"
