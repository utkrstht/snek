#!/usr/bin/env bash
set -euo pipefail

cd scripts

bash ./build.sh
echo "building"

bash ./run.sh
echo "running, done."