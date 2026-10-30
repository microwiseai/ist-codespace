#!/usr/bin/env bash
# Smoke test for the Codespace image. Runs INSIDE the built image, as `node`:
#
#   docker run --rm -v "$PWD/.devcontainer:/smoke:ro" <image> bash /smoke/smoke-test.sh
#
# Used by .github/workflows/image.yml as the gate for promoting :stable, and
# runnable locally against any candidate image. Covers what a workshop user
# relies on without logging in to anything:
#   1. CLIs on PATH (and they run)
#   2. `snapshot install @ist/beta` fully succeeded (partial failure = failure)
#   3. required skit kits installed
#   4. IST UI really starts (via start-ui.sh, the postStartCommand) and answers HTTP on 7788
#   5. isesh can start / list / stop a tmux-backed session
#
# Exit 0 only if every check passes. Each check prints "PASS:" / "FAIL:" / "WARN:".

set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SNAPSHOT_LOG="${SNAPSHOT_LOG:-$HOME/.cache/ist-codespace/snapshot-install.log}"
UI_PORT="${IST_UI_PORT:-7788}"
REQUIRED_CMDS=(isesh itda skit snapshot claude codex ist-ui glpkg tmux curl)
OPTIONAL_CMDS=(istate)
REQUIRED_KITS=(@ist/tda-kit @ist/messenger-kit @ist/smon-kit)

fails=0
pass() { echo "PASS: $*"; }
fail() { echo "FAIL: $*"; fails=$((fails + 1)); }
warn() { echo "WARN: $*"; }
section() { echo; echo "== $*"; }

# ---------------------------------------------------------------------------
section "1. commands"
for c in "${REQUIRED_CMDS[@]}"; do
  if command -v "$c" >/dev/null 2>&1; then pass "$c on PATH"; else fail "$c not on PATH"; fi
done
for c in "${OPTIONAL_CMDS[@]}"; do
  command -v "$c" >/dev/null 2>&1 && pass "$c on PATH" || warn "$c not on PATH (optional)"
done
for c in isesh itda skit snapshot claude codex ist-ui; do
  command -v "$c" >/dev/null 2>&1 || continue
  if v="$(timeout 30 "$c" --version 2>&1)"; then pass "$c --version: $(echo "$v" | head -1)"
  else fail "$c --version exited non-zero: $(echo "$v" | head -3)"; fi
done

# ---------------------------------------------------------------------------
section "2. snapshot install @ist/beta"
if [ ! -s "$SNAPSHOT_LOG" ]; then
  fail "no snapshot install log at $SNAPSHOT_LOG"
else
  # strip ANSI colors before matching
  log="$(sed 's/\x1b\[[0-9;]*m//g' "$SNAPSHOT_LOG")"
  summary="$(grep -Eo 'Installed: *[0-9]+/[0-9]+' <<<"$log" | tail -1)"
  if [ -z "$summary" ]; then
    fail "no 'Installed: N/M' summary in install log"
  else
    n="$(sed -E 's#.*: *([0-9]+)/([0-9]+)#\1#' <<<"$summary")"
    m="$(sed -E 's#.*: *([0-9]+)/([0-9]+)#\2#' <<<"$summary")"
    if [ "$n" = "$m" ] && [ "$m" -gt 0 ]; then pass "$summary"; else fail "partial install — $summary"; fi
  fi
  if grep -qE '^Failed:' <<<"$log"; then
    fail "install log has failed packages: $(awk '/^Failed:/{f=1;next} f&&/✗/{printf "%s ", $2} f&&!/✗/{f=0}' <<<"$log")"
  else
    pass "no 'Failed:' section in install log"
  fi
fi
if j="$(snapshot current --json 2>/dev/null)"; then
  if node -e '
      const d = JSON.parse(require("fs").readFileSync(0, "utf8"));
      const v = (d.ledger || {}).verification;
      if (!d.current || !d.current.name) { console.log("no current snapshot"); process.exit(1); }
      if (v && v.ok === false) { console.log("ledger verification mismatches: " + JSON.stringify(v.mismatches)); process.exit(1); }
      console.log(d.current.name + "@" + d.current.version + ", " + (d.current.packages || []).length + " packages" +
        (v ? ", verified " + v.verifiedCount + "/" + v.total : ""));' <<<"$j" >/tmp/smoke-ledger 2>&1
  then pass "ledger: $(cat /tmp/smoke-ledger)"; else fail "ledger: $(cat /tmp/smoke-ledger)"; fi
else
  fail "snapshot current --json failed"
fi

# ---------------------------------------------------------------------------
section "3. skit kits"
kits="$(skit list 2>&1)"
for k in "${REQUIRED_KITS[@]}"; do
  if grep -qF -- "$k " <<<"$kits"; then pass "$k installed"; else fail "$k not in 'skit list'"; fi
done

# ---------------------------------------------------------------------------
section "4. IST UI on :$UI_PORT (via start-ui.sh)"
export IST_UI_LOG=/tmp/smoke-start-ui.log
if [ -x "$SCRIPT_DIR/start-ui.sh" ] || [ -f "$SCRIPT_DIR/start-ui.sh" ]; then
  bash "$SCRIPT_DIR/start-ui.sh" >/dev/null 2>&1
else
  timeout 30 ist-ui --no-open --port "$UI_PORT" >/dev/null 2>&1
fi
code=000
for _ in $(seq 1 20); do
  code="$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$UI_PORT/" || true)"
  [ "$code" != "000" ] && break
  sleep 1
done
# Without the token the UI must answer (401 = up and guarded).
if [ "$code" != "000" ] && [ "$code" -lt 500 ]; then pass "GET / -> HTTP $code"
else fail "no HTTP answer on :$UI_PORT (code $code); start-ui log: $(tail -5 "$IST_UI_LOG" 2>/dev/null)"; fi
url="$(ist-ui url 2>/dev/null)"
if [ -n "$url" ]; then
  code="$(curl -s -o /dev/null -w '%{http_code}' "$url" || true)"
  case "$code" in 2??|3??) pass "GET tokenized URL -> HTTP $code" ;; *) fail "tokenized URL -> HTTP $code" ;; esac
else
  fail "ist-ui url printed nothing"
fi
ist-ui stop >/dev/null 2>&1 || true

# ---------------------------------------------------------------------------
section "5. isesh session (tmux)"
ws="$(mktemp -d)"
name="smoke-$$"
if out="$(cd "$ws" && timeout 60 isesh start "$name" -d -w "$ws" --cli claude 2>&1)"; then
  pass "isesh start -d"
else
  fail "isesh start failed: $(echo "$out" | tail -5)"
fi
sleep 3
if tmux has-session -t "ist--$name" 2>/dev/null; then pass "tmux session ist--$name exists"
else fail "tmux session ist--$name missing ($(tmux ls 2>&1 | head -3))"; fi
if isesh list 2>&1 | grep -q "$name"; then pass "isesh list shows $name"; else fail "isesh list doesn't show $name"; fi
if timeout 30 isesh stop "$name" >/dev/null 2>&1 && ! tmux has-session -t "ist--$name" 2>/dev/null; then
  pass "isesh stop"
else
  fail "isesh stop didn't end the tmux session"
fi
isesh delete "$name" --all >/dev/null 2>&1 || true
tmux kill-server >/dev/null 2>&1 || true

# ---------------------------------------------------------------------------
echo
if [ "$fails" -eq 0 ]; then echo "== SMOKE TEST PASSED"; exit 0; fi
echo "== SMOKE TEST FAILED ($fails check(s))"
exit 1
