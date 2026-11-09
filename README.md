<p align="center"><b>English</b> | <a href="./README.ko.md">한국어</a></p>

# IST Workshop Codespace

A ready-to-use GitHub Codespace for trying **IST (Integrated Session Tools)**: you
write no code — you start an AI *manager* session, paste one prompt, and watch it
split the work across AI *worker* sessions that build real software. Everything
(`isesh` toolchain, the IST UI, Claude Code, OpenAI Codex, tmux) is pre-installed.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/microwiseai/ist-codespace?quickstart=1)

## Open the IST UI

When the Codespace starts, the **IST UI** server starts automatically in the background
(forwarded port **7788**, labelled *IST UI*). The Codespace also tries to open it in a new
browser tab, but browsers often block that pop-up. **If no IST UI tab opened, open it
yourself:**

- in the terminal, run `ist-ui`. It prints the URL (and starts the server if it isn't
  running). Click the `https://…-7788…` link it prints, **or**
- **Ports** panel → `7788` → globe icon (*Open in Browser*).

```bash
ist-ui         # starts it if needed and prints the URL
ist-ui url     # just prints https://<your-codespace>-7788.<forwarding-domain>/
```

Use the same steps whenever you lose the tab. The IST UI is the main entry point, with two
tabs:

- **Setup** — sign-ins and background services: **IST account (detector-agent)**,
  **Claude Code**, **Codex CLI**, and the **detector-agent** background agent. You can log in
  to Claude Code / Codex right from their cards. The UI opens here (tab badge **!**) while
  Claude Code or Codex still needs to be installed or signed in.
- **Managers** — **＋ New manager** (pick a folder, or **Use another folder**; with no
  managers yet the page shows one big **▶ Start a manager in this folder**), then one row per
  manager with **▶ Start** / **■ Stop**, **Copy attach command** (paste it into a terminal to
  talk to the manager) and its worker count. Once you're logged in, the UI opens here.

**Troubleshooting**

- **No IST UI tab opened at start** — this is normal: the browser blocked the pop-up, but
  the server is already running. Open it with `ist-ui` or **Ports** → `7788` → globe icon
  (see above). If your browser shows a "pop-up blocked" icon in the address bar, you can
  allow pop-ups for `*.github.dev`.
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
  - **Claude Code** — a Claude Pro/Max subscription **or** an [Anthropic API key](https://console.anthropic.com/)
  - **OpenAI Codex** — a ChatGPT plan **or** an [OpenAI API key](https://platform.openai.com/api-keys)

  How to sign in: [Log in](#log-in).

## Log in

Nothing is injected into the Codespace — you log in yourself, once, in the IST UI's
**Setup** tab: on the **Claude Code** or **Codex CLI** card, log in until it says **Ready**
(the tab shows a **!** badge until then). You need just one of the two.

**Alternative — terminal** (e.g. the IST UI won't open, or you'd rather use an API key):

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

## Updating the Image

A Codespace pulls the image pinned by digest in `.devcontainer/devcontainer.json`; it
never builds the Dockerfile, and no CI builds or updates the image. The image that runs
is the one you built and tested locally. After changing the pinned versions in
`.devcontainer/Dockerfile`:

```bash
docker build --pull --no-cache -t ist-codespace:candidate .devcontainer
docker run --rm -v "$PWD/.devcontainer:/smoke:ro" ist-codespace:candidate bash /smoke/smoke-test.sh

# Run the candidate as a real dev container, then check start-ui.sh, welcome.sh, isesh, ist-ui, port 7788
sed 's#"image": ".*"#"image": "ist-codespace:candidate"#' .devcontainer/devcontainer.json > /tmp/candidate.json
npx @devcontainers/cli up --workspace-folder . --override-config /tmp/candidate.json

# If everything passed (needs a docker login to ghcr.io)
tag="$(date +%Y%m%d)-$(git rev-parse --short HEAD)"
docker tag ist-codespace:candidate "ghcr.io/microwiseai/ist-codespace:$tag"
docker push "ghcr.io/microwiseai/ist-codespace:$tag"   # prints digest: sha256:...
```

Then set `"image"` in `devcontainer.json` to `ghcr.io/microwiseai/ist-codespace@sha256:...`
with that digest, commit and push.

A Codespaces Prebuild is not needed, since nothing is built on open. It is optional and
only saves the image pull.

## Project Structure

```
workshops/
  README.md            # workshop index
  00-quicktool/        # README + guide/ (steps) + project/ (spec, manager prompt, starter config)
  01-tetris/           # README + project/
  02-converter-kit/    # README + project/
.devcontainer/
  Dockerfile           # image recipe, pinned versions: isesh / snapshot / claude-code / codex / ist-ui (via glpkg)
  devcontainer.json    # image digest, ports 7788 (IST UI) + 9876 (detector-agent login), start/attach hooks
  start-ui.sh          # postStartCommand: launches the IST UI in the background
  welcome.sh           # postAttachCommand: welcome banner
  smoke-test.sh        # image gate: CLIs, full snapshot install, kits, IST UI HTTP, isesh/tmux
```
