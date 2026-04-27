#!/bin/bash
cd /home/container || exit 1

echo "Container starting..."
echo "User: $(whoami)"
echo "Working dir: $(pwd)"

if [ -z "${STARTUP}" ]; then
  echo "No STARTUP variable defined"
  exit 1
fi

echo "Running startup command: ${STARTUP}"
exec bash -c "${STARTUP}"
