# Workshop 01 — Build Tetris with IST

**Goal:** Have a team of AI agents build a playable browser Tetris game, with tested
game logic, from a one-page spec. You write no code: you start a manager, paste one
prompt, watch, and play the result.

**Time:** ~60 minutes

**Before you start:** do [Workshop 00 — quicktool](../00-quicktool/README.md) first if
you're new to IST, and log in to your AI CLI (see the [root README](../../README.md#log-in)).

## What You'll Learn

- Writing a spec with an explicit **contract** (the Game API) so workers can build in parallel
- Running **parallel workers** — engine and tests written at the same time against the same contract
- **File ownership**: each worker owns specific files, so they don't step on each other
- Letting tests decide whether the code or the test is wrong
- Serving a web app from a Codespace through a **forwarded port**

## What Gets Built

```
index.html + src/game/*.js (pure engine) + src/render.js / input.js / main.js + test/*.test.js
```

- 10×20 board, all 7 tetrominoes, rotation with wall kicks, line clear
- Score / level / lines, next-piece preview, pause, game over + restart
- Unit tests for the engine with Node's built-in runner (`npm test`)
- Plain HTML/JS — no framework, no build step, no dependencies. Served by a tiny
  Node server on **port 8080**.

## Files

| File | What it is |
|------|-----------|
| [`project/project-brief.md`](project/project-brief.md) | The product spec (features, controls, architecture, Game API, success criteria) |
| [`project/manager-prompt.md`](project/manager-prompt.md) | The prompt you paste into the manager |
| [`project/package.json`](project/package.json) | Starter config: `npm start` (server on 8080), `npm test` (`node --test`) |

## Steps

### 1. Read the spec (5 min)

Open [`project/project-brief.md`](project/project-brief.md). Notice the **Game API** section:
it is the contract the engine worker implements and the tests worker tests against —
that's what lets them work at the same time.

### 2. Start the manager — in the IST UI (2 min)

The IST UI opens in a browser tab when the Codespace starts (port **7788**). Lost the
tab? **Ports** panel → `7788` → globe icon, or run `ist-ui url`.

1. **Setup** tab — confirm your AI CLI is logged in.
2. **Managers** tab → **▶ Start a manager in this folder**.
3. Set the folder to `/workspaces/ist-codespace/workshops/01-tetris/project`
   (or **Use another folder** and paste it). Keep the suggested name (e.g. `project-mgr`) or pick any name — the prompt works with whatever the manager is called. Start it.

<details>
<summary>CLI equivalent</summary>

```bash
cd /workspaces/ist-codespace
isesh start project-mgr -w ./workshops/01-tetris/project
isesh list          # project-mgr → active
```
</details>

### 3. Paste the manager prompt (1 min)

Copy all of [`project/manager-prompt.md`](project/manager-prompt.md) (everything below the
`---`) and paste it into the manager session (attach to it from the UI, or `isesh attach <manager>`).

### 4. Watch the team work (30–40 min)

The manager runs three phases:

Workers are named after your manager — `<manager>` below is its name (e.g. `project-mgr`).

| Phase | Workers | What happens |
|-------|---------|-------------|
| 1 | `<manager>-engine` + `<manager>-tests` (parallel) | Pure game engine and its unit tests, both from the Game API |
| 2 | `<manager>-ui` | `index.html`, canvas rendering, keyboard input, the dev server |
| 3 | manager | Runs the tests, checks the success criteria, asks you to play |

Workers appear in the UI's **Managers** tab under your manager. To follow along in a terminal:

<details>
<summary>CLI monitoring</summary>

```bash
smon watch '<manager>-*' -n <manager> -d   # relay worker state (idle / permission / exit) to the manager
ilogsession tail <manager>-engine      # follow one worker's log
isesh list
```
</details>

Watch for the moment the tests worker reports a failure and the manager routes it
back to the engine worker — that's the loop doing its job.

### 5. Play it (10 min)

When the manager says Phase 2 is done:

```bash
cd /workspaces/ist-codespace/workshops/01-tetris/project
npm test
npm start            # serves on port 8080
```

Codespaces forwards port **8080** automatically: click **Open in Browser** in the
notification, or **Ports** panel → `8080` → globe icon. Controls: ← → move, ↓ soft drop,
Space hard drop, ↑/X rotate, Z rotate back, P pause, Enter start/restart.

Found a bug? Tell the manager in plain words ("rotation near the right wall doesn't
kick") and let it route the fix.

## Try Next

- Ask the manager for a feature: hold piece, ghost piece, high score in `localStorage`.
- Then try [Workshop 02 — converter kit](../02-converter-kit/README.md): a real-world parsing job.
