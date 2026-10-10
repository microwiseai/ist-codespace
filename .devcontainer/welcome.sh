#!/usr/bin/env bash
# Printed on every attach (postAttachCommand). Keep it fast — no installs here.
# no `set -e`: an attach banner must never fail

cat <<'BANNER'

╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   Welcome to the IST Workshop 🎉                                 ║
║   Build software with a team of AI agents.                       ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

  isesh / ist-ui / snapshot / claude-code / codex are already installed in this image.

  ─────────────────────────────────────────────────────────────────
  START HERE:  README.md  →  workshops/README.md
  ─────────────────────────────────────────────────────────────────

  STEP 1 — Log in to your AI CLI (needed before agents can run).
           Pick one (or both) — nothing is injected, you log in yourself:

     claude login                 # Claude Code — Claude Pro/Max subscription
     #   ...or use an API key:
     export ANTHROPIC_API_KEY=sk-ant-...

     codex login --device-auth    # OpenAI Codex — ChatGPT plan (device code)
     #   ...or use an API key (read from stdin):
     printenv OPENAI_API_KEY | codex login --with-api-key

  STEP 2 — (optional) Enable monitoring / auto-approval, one time:

     detector-agent login         # interactive Google login, once

  STEP 3 — Pick a workshop (workshops/README.md):

     workshops/00-quicktool/      # ~30 min — a small CLI (start here)
     workshops/01-tetris/         # ~60 min — browser Tetris
     workshops/02-converter-kit/  # ~90 min — HWP/HWPX → Markdown converter

  Tip: a tmux-capable terminal is expected (tmux is installed).

BANNER

# Primary entry: the IST UI (port 7788). Fallback: the CLI. Never fails.
if command -v ist-ui >/dev/null 2>&1; then
  echo "  ★ IST UI — opens automatically in a browser tab (port 7788)."
  url="$(ist-ui url 2>/dev/null)" && [ -n "$url" ] && echo "     URL: $url"
  echo "     Reopen: Ports panel → 7788 → globe icon, or run: ist-ui url"
  echo "     Asks for a token? Open the URL from ist-ui url. Trouble? ist-ui status"
  echo "  CLI fallback: isesh start project-mgr -w ./workshops/00-quicktool/project"
else
  echo "  ist-ui not found — use the CLI flow:"
  echo "     isesh start project-mgr -w ./workshops/00-quicktool/project"
fi
echo ""

# Show installed versions if available (non-fatal).
if command -v isesh >/dev/null 2>&1; then
  echo "  Installed isesh: $(isesh --version 2>/dev/null || echo unknown)"
fi
echo ""
