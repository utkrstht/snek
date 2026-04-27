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

run_qemu_with_backend() {
  local backend="$1"
  echo "Starting QEMU audio backend: $backend"
  "$QEMU_BIN" \
    -m 16M \
    -drive file=../dist/snek.img,format=raw,if=floppy \
    -audiodev "$backend",id=snd0 \
    -machine pcspk-audiodev=snd0 \
    -boot a
}

audio_backend="${SNEK_AUDIO_BACKEND:-}"
if [ -n "$audio_backend" ]; then
  run_qemu_with_backend "$audio_backend"
  exit $?
fi

drivers="$($QEMU_BIN -audiodev help 2>/dev/null || true)"
backend_candidates=()

if printf '%s\n' "$drivers" | grep -qx 'pa'; then
  backend_candidates+=("pa")
fi
if printf '%s\n' "$drivers" | grep -qx 'sdl'; then
  backend_candidates+=("sdl")
fi
if printf '%s\n' "$drivers" | grep -qx 'alsa'; then
  backend_candidates+=("alsa")
fi
if printf '%s\n' "$drivers" | grep -qx 'pipewire'; then
  backend_candidates+=("pipewire")
fi
backend_candidates+=("none")

for backend in "${backend_candidates[@]}"; do
  if run_qemu_with_backend "$backend"; then
    exit 0
  fi
  echo "QEMU audio backend '$backend' failed, trying next..." >&2
done

echo "Error: could not launch QEMU with any audio backend." >&2
exit 1
