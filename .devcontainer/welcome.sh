#!/usr/bin/env bash
# Printed on every attach (postAttachCommand). Keep it fast — no installs here.
set -e

cat <<'BANNER'

╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   Welcome to the IST Workshop 🎉                                 ║
║   Build a CLI tool in ~30 min using AI agent sessions.           ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

  isesh / snapshot / claude-code / codex are already installed in this image.

  ─────────────────────────────────────────────────────────────────
  START HERE:  guide/README.md
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

  Then follow the workshop:

     cat guide/README.md
     isesh start mgr -w ./project

  Tip: a tmux-capable terminal is expected (tmux is installed).

BANNER

# Show installed versions if available (non-fatal).
if command -v isesh >/dev/null 2>&1; then
  echo "  Installed isesh: $(isesh --version 2>/dev/null || echo unknown)"
fi
echo ""
