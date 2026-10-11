#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p test -n "${CAPTURE_URL:?CAPTURE_URL must be set to the exact URL to capture}"
/usr/bin/time -p test -n "${CAPTURE_DIR:?CAPTURE_DIR must be set to the output directory}"
/usr/bin/time -p test -n "${RUNTIME_DIR:?RUNTIME_DIR must be set}"
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p node "${RUNTIME_DIR}/scripts/default-capture.mjs"
status=$?
if [[ $status -ne 0 ]]; then
  echo "capture failed with exit $status" >&2
  exit "$status"
fi
/usr/bin/time -p test -f "$CAPTURE_DIR/final-desktop.png"
/usr/bin/time -p test -f "$CAPTURE_DIR/final-mobile.png"
/usr/bin/time -p ls -l "$CAPTURE_DIR/final-desktop.png" "$CAPTURE_DIR/final-mobile.png"
