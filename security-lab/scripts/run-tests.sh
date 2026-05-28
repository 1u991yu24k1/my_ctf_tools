#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-tsan}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="$ROOT/build-$MODE"
OUT="$ROOT/security-lab/artifacts/$MODE"

mkdir -p "$OUT"

export TSAN_OPTIONS="halt_on_error=0 history_size=7 second_deadlock_stack=1 log_path=$OUT/tsan"
export ASAN_OPTIONS="halt_on_error=0 detect_leaks=1 log_path=$OUT/asan"
export UBSAN_OPTIONS="halt_on_error=0 print_stacktrace=1 log_path=$OUT/ubsan"

ctest --test-dir "$BUILD" --output-on-failure 2>&1 | tee "$OUT/ctest.log" || true

find "$OUT" -type f -maxdepth 1 -print > "$OUT/files.txt"
