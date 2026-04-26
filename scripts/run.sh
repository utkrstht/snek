#!/usr/bin/env bash
set -euo pipefail

bash ./build.sh

QEMU_BIN=""
if command -v qemu-system-i386 >/dev/null 2>&1; then
  QEMU_BIN="qemu-system-i386"
elif command -v qemu-system-x86_64 >/dev/null 2>&1; then
  QEMU_BIN="qemu-system-x86_64"
else
  echo "Error: QEMU not found in PATH." >&2
  echo "Run ./setup.sh to install dependencies." >&2
  exit 1
fi

exec "$QEMU_BIN" \
  -m 16M \
  -drive file=../dist/snek.img,format=raw,if=floppy \
  -boot a
