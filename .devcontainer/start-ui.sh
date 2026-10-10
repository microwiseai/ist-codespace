#!/usr/bin/env bash
# postStartCommand: launch the IST UI (ist-ui, port 7788) in the background.
#
# Contract:
#   - lightweight + non-blocking: `ist-ui --no-open` daemonizes and returns
#   - idempotent: ist-ui reuses an already-running server
#   - never fails the Codespace start: every path exits 0
#   - logs to $IST_UI_LOG (default ~/.cache/ist-codespace/start-ui.log)
#
# ist-ui is baked into the image (Dockerfile, via glpkg). The `command -v` guard is
# only a defensive fallback: if it's missing we print a note and the CLI flow (isesh) still works.

PORT="${IST_UI_PORT:-7788}"
LOG="${IST_UI_LOG:-$HOME/.cache/ist-codespace/start-ui.log}"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || LOG=/dev/null

# Start the UI from the workspace root so "Start a manager in this folder"
# points at the repo (workshops/ is one click away from there).
cd "$(dirname "$0")/.." 2>/dev/null || true

(
  echo "[$(date -Is)] start-ui: cwd=$(pwd) port=$PORT"
  if ! command -v ist-ui >/dev/null 2>&1; then
    echo "ist-ui not found — skipping. Use the CLI: isesh start ..."
    exit 0
  fi
  # timeout guards against a hang ever blocking the Codespace start.
  if timeout 30 ist-ui --no-open --port "$PORT"; then
    echo "ist-ui started (or already running): $(ist-ui url 2>/dev/null || echo "port $PORT")"
  else
    echo "ist-ui failed to start (exit $?). Try: ist-ui status"
  fi
) >>"$LOG" 2>&1

if command -v ist-ui >/dev/null 2>&1; then
  echo "IST UI: port $PORT (log: $LOG)"
else
  echo "ist-ui not found — use the CLI (see README). Log: $LOG"
fi
exit 0
