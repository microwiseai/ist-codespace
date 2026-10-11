# IST Workshops

Each workshop is one folder: a `README.md` (the steps) and a `project/` folder (the
product spec, the manager prompt, and starter config). The `project/` folder is the
manager's workspace — you start a manager there, paste the prompt, and the agents build.

| # | Workshop | Time | You'll build | New ideas |
|---|----------|------|--------------|-----------|
| 00 | [quicktool](00-quicktool/README.md) | ~30 min | A small developer CLI (time / json / encode) | Sessions, manager → workers, monitoring |
| 01 | [Build Tetris with IST](01-tetris/README.md) | ~60 min | Browser Tetris with a tested game engine | A contract in the spec, parallel workers, file ownership, forwarded ports |
| 02 | [Build a converter kit with IST](02-converter-kit/README.md) | ~90 min | HWP / HWPX → Markdown CLI + library | Format research up front, intermediate model, synthetic fixtures vs. private real files |

New to IST? Start with **00**.

## The same flow every time

1. Log in to your AI CLI once (see the [root README](../README.md#log-in)).
2. In the **IST UI** (port 7788; no tab opened? run `ist-ui` and click the URL): **Setup** tab — make sure Claude Code
   or Codex says **Ready** → **Managers** tab → **＋ New manager** with **Folder** = the
   workshop's `project/` folder → **▶ Start** → **Copy attach command** into a terminal.
3. Paste `project/manager-prompt.md` into the manager.
4. Watch the workers, then try what they built.

CLI equivalent of step 2: `isesh start <name> -w ./workshops/<NN-name>/project`.
