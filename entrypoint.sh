#!/bin/bash
cd /home/container || exit 1

echo "User: $(whoami)"
echo "Dir: $(pwd)"
echo "Haxe: $(haxe --version)"
echo "Haxelib ready"

exec bash -lc "${STARTUP}"
