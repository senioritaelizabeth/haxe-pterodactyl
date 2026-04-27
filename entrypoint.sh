#!/bin/bash
cd /home/container || exit 1

echo "User: $(whoami)"
echo "Dir: $(pwd)"
echo "Haxe: $(haxe --version)"
echo "Neko: $(neko -version || true)"

if [ -z "${STARTUP}" ]; then
  echo "STARTUP no definido"
  exit 1
fi

exec bash -lc "${STARTUP}"
