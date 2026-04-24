#!/usr/bin/env bash
set -euo pipefail

if ! command -v nasm >/dev/null 2>&1; then
  echo "Error: nasm not found in PATH." >&2
  echo "Install with: sudo apt update && sudo apt install -y nasm" >&2
  exit 1
fi

mkdir -p ../dist

nasm -f bin ../stage1.asm -o ../dist/stage1.bin
nasm -f bin ../stage2.asm -o ../dist/stage2.bin

stage1_size=$(stat -c%s ../dist/stage1.bin)
if [ "$stage1_size" -ne 512 ]; then
  echo "Error: stage1.bin need to be exactly 512 bytes :< (got $stage1_size)." >&2
  exit 1
fi

truncate -s 1474560 ../dist/snek.img

dd if=../dist/stage1.bin of=../dist/snek.img bs=512 seek=0 conv=notrunc status=none
dd if=../dist/stage2.bin of=../dist/snek.img bs=512 seek=1 conv=notrunc status=none

echo "Built snek.img"
