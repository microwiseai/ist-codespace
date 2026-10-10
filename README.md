# IST Workshop Codespace

A ready-to-use GitHub Codespace for trying **IST (Integrated Session Tools)**: you
write no code — you start an AI *manager* session, paste one prompt, and watch it
split the work across AI *worker* sessions that build real software. Everything
(`isesh` toolchain, the IST UI, Claude Code, OpenAI Codex, tmux) is pre-installed.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/microwiseai/ist-codespace?quickstart=1)

## The IST UI opens automatically

When the Codespace starts, the **IST UI** launches in the background and opens in a new
browser tab (forwarded port **7788**, labelled *IST UI*). It's the main entry point, with
two tabs:

- **Setup** — sign-ins and background services: **IST account (detector-agent)**,
  **Claude Code**, **Codex CLI**, and the **detector-agent** background agent. You can log in
  to Claude Code / Codex right from their cards. The UI opens here (tab badge **!**) while
  Claude Code or Codex still needs to be installed or signed in.
- **Managers** — **＋ New manager** (pick a folder, or **Use another folder**; with no
  managers yet the page shows one big **▶ Start a manager in this folder**), then one row per
  manager with **▶ Start** / **■ Stop**, **Copy attach command** (paste it into a terminal to
  talk to the manager) and its worker count. Once you're logged in, the UI opens here.

**Reopen it:** **Ports** panel → `7788` → globe icon (*Open in Browser*), or in a terminal:

```bash
ist-ui url     # prints https://<your-codespace>-7788.<forwarding-domain>/
ist-ui         # starts it if needed and prints the URL
```

**Troubleshooting**

- **The page asks for a token** — you opened a `localhost`/`127.0.0.1` address. Run
  `ist-ui url` and open the `https://…-7788…` address it prints instead.
- **Nothing on port 7788** — `ist-ui status`. Restart with `ist-ui stop` then `ist-ui`.
  Logs: `~/.cache/ist-codespace/start-ui.log` (Codespace start) and `~/.ist/ui/serve.log` (the UI server).
- **Never make port 7788 Public.** Keep its visibility *Private* (the default): through the
  forwarded address the UI needs no token — GitHub's sign-in is what protects it — and
  whoever reaches it can sign accounts in and out and start or stop agents.

## Workshops

| # | Workshop | Time |
|---|----------|------|
| 00 | [quicktool — build a CLI in 30 minutes](workshops/00-quicktool/README.md) | ~30 min |
| 01 | [Build Tetris with IST](workshops/01-tetris/README.md) | ~60 min |
| 02 | [Build a converter kit with IST (HWP / HWPX → Markdown)](workshops/02-converter-kit/README.md) | ~90 min |

New to IST? Start with **00**. Overview: [workshops/README.md](workshops/README.md).

## Prerequisites

- A GitHub account
- A way to authenticate an AI CLI (both are pre-installed):
  - **Claude Code** — a Claude Pro/Max subscription (`claude login`) **or** an [Anthropic API key](https://console.anthropic.com/)
  - **OpenAI Codex** — a ChatGPT plan (`codex login --device-auth`) **or** an [OpenAI API key](https://platform.openai.com/api-keys)

## Log in

Nothing is injected into the Codespace — you log in yourself. Easiest: the IST UI's
**Setup** tab (**Claude Code** / **Codex CLI** cards). Or in a terminal:

```bash
# Claude Code
claude login                                  # Claude Pro/Max subscription
export ANTHROPIC_API_KEY=sk-ant-...           # ...or an API key

# OpenAI Codex
codex login --device-auth                     # ChatGPT plan (device code)
printenv OPENAI_API_KEY | codex login --with-api-key   # ...or an API key
```

**Optional — auto-approval & web dashboard:** sign in on the **IST account (detector-agent)**
card (**Sign in with Google**), or run `detector-agent login` once (its OAuth callback uses
forwarded port 9876). Then `smon`
can auto-approve routine agent prompts, and you can watch sessions live at
https://ism.microwiseai.com.

## How It Works

You paste a manager prompt into an AI session. The manager:
1. Reads the product spec
2. Creates worker sessions for each phase
3. Workers write code (in parallel where the spec allows)
4. The manager reviews and tests; you watch everything live

No code writing. Just orchestration.

## Speeding Up with Prebuilds

The devcontainer bakes the whole toolchain into the image, so a **Codespaces
Prebuild** makes every "Open in Codespaces" fast. Repo/org owner, one time:

1. Go to the repo on GitHub → **Settings → Codespaces → Prebuilds → Set up prebuild**
   (org-wide: **Org Settings → Codespaces → Prebuilds**).
2. Pick this repository and the branch (e.g. `main`).
3. Choose region(s) near your users, then save.

GitHub builds the image ahead of time and refreshes it on pushes that change
`.devcontainer/**`. After the first prebuild, opening a Codespace uses the cache.
(The IST UI is started by `postStartCommand`, which runs at container start — not
during the prebuild — so prebuilds are unaffected.)

## Project Structure

```
workshops/
  README.md            # workshop index
  00-quicktool/        # README + guide/ (steps) + project/ (spec, manager prompt, starter config)
  01-tetris/           # README + project/
  02-converter-kit/    # README + project/
.devcontainer/
  Dockerfile           # prebakes isesh / snapshot / claude-code / codex / ist-ui (via glpkg)
  devcontainer.json    # ports 7788 (IST UI) + 9876 (detector-agent login), start/attach hooks
  start-ui.sh          # postStartCommand: launches the IST UI in the background
  welcome.sh           # postAttachCommand: welcome banner
```
