#!/usr/bin/env bash
set -euo pipefail

echo "snek setup!!"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Error: apt-get not found. This script requires bash shell. Are you on Windows?" >&2
  exit 1
fi

echo "installing nasm"
sudo apt-get install -y nasm >/dev/null

echo "installing qemu"
sudo apt-get install -y qemu-system-x86 >/dev/null

echo "setup done, you can run snek now!!"