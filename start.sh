#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PROJECT_ROOT="$PWD"
PORT="${PORT:-3000}"
DIST_DIR="$PROJECT_ROOT/dist"
DEPLOY_FILE="${OPENCODE_WEB_DIR:?OPENCODE_WEB_DIR must be set}/deployment-output.json"
/usr/bin/time -p mkdir -p "$DIST_DIR"
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  if [[ -f "$PROJECT_ROOT/package-lock.json" ]]; then
    /usr/bin/time -p npm ci --no-audit --no-fund
  else
    /usr/bin/time -p npm install --no-audit --no-fund
  fi
  if /usr/bin/time -p npm run --silent build 2>/dev/null; then
    true
  else
    echo "no build script; using existing static output" >&2
  fi
else
  /usr/bin/time -p test -f "$PROJECT_ROOT/index.html"
fi
if [[ ! -f "$DIST_DIR/index.html" ]]; then
  /usr/bin/time -p cp "$PROJECT_ROOT/index.html" "$DIST_DIR/index.html"
elif [[ -f "$PROJECT_ROOT/index.html" && "$PROJECT_ROOT/index.html" -nt "$DIST_DIR/index.html" ]]; then
  /usr/bin/time -p cp "$PROJECT_ROOT/index.html" "$DIST_DIR/index.html"
fi
/usr/bin/time -p test -f "$DIST_DIR/index.html"
/usr/bin/time -p mkdir -p "$(dirname "$DEPLOY_FILE")"
/usr/bin/time -p python3 -c 'import json,sys; json.dump({"project":sys.argv[1],"directory":sys.argv[2]}, open(sys.argv[3],"w"))' "$PROJECT_ROOT" "$DIST_DIR" "$DEPLOY_FILE"
/usr/bin/time -p cat "$DEPLOY_FILE"
/usr/bin/time -p python3 --version
exec /usr/bin/time -p python3 -m http.server "$PORT" --directory "$DIST_DIR"
