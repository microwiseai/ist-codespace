# Workshop 02 — Build a converter kit with IST (HWP / HWPX → Markdown)

**Goal:** Have a team of AI agents build **hwpconv**, a Node/TypeScript CLI + library that
turns Korean `.hwp` (HWP 5.0) and `.hwpx` documents into Markdown and plain text. This is
a real-world job: two file formats, one binary and one XML, built by separate workers
against a shared model, then checked against your own documents.

**Time:** ~90 minutes

**Before you start:** do [Workshop 00 — quicktool](../00-quicktool/README.md) first if you're
new to IST, and log in to your AI CLI (see the [root README](../../README.md#log-in)).

## What You'll Learn

- Speccing a **format-conversion** project: an intermediate model (`Doc`) as the contract
  between parsers and renderers
- Running **two parser workers in parallel** after a core worker lays the foundation
- Giving agents **format research up front** (spec notes, verified npm packages with
  licenses) so they don't guess or invent dependencies
- **Synthetic test fixtures** built in code vs. **your private real documents** for integration
- Steering the manager with real-world bug reports

## What Gets Built

```bash
hwpconv report.hwpx                  # Markdown to stdout
hwpconv report.hwp -o report.md
hwpconv report.hwp --format text
hwpconv docs/*.hwp* --out-dir out/   # batch
hwpconv info report.hwp              # version, compressed/encrypted, counts
```

Paragraphs, headings (where the document uses outline/개요 styles) and tables
(best-effort, as Markdown tables). **Only `.hwp` (5.0) and `.hwpx`** — other formats are out of scope.

## Files

| File | What it is |
|------|-----------|
| [`project/project-brief.md`](project/project-brief.md) | The product spec: CLI, API, `Doc` model, **format notes**, verified libraries, output rules, acceptance criteria |
| [`project/manager-prompt.md`](project/manager-prompt.md) | The prompt you paste into the manager |
| [`project/package.json`](project/package.json), [`project/tsconfig.json`](project/tsconfig.json) | Starter config: TypeScript ESM, `cfb` / `fflate` / `@xmldom/xmldom` / `commander`, `npm test` = `node --test` running `.ts` directly |
| `project/samples/private/` | Where **your** documents go (git-ignored; create it) |

## Steps

### 1. Read the spec and get sample documents (10 min)

Read [`project/project-brief.md`](project/project-brief.md) — at least **Format notes** and
**Sample files**. Then collect a few documents:

```bash
mkdir -p /workspaces/ist-codespace/workshops/02-converter-kit/project/samples/private
```

Upload `.hwp` / `.hwpx` files there (drag them into the VS Code Explorer). Best: one
document with a heading, a few paragraphs and a table, saved **both** as `.hwp` and
`.hwpx` from Hancom Office / Hancom Docs. Public-sector documents downloaded from the web
work too. No documents? Fine — the workers' tests use synthetic fixtures; you'll just skip
the real-document check in step 5.

> These files stay private: `samples/private/` is in `.gitignore`, and the prompt tells
> the agents never to commit them.

### 2. Start the manager — in the IST UI (2 min)

The IST UI opens in a browser tab when the Codespace starts (port **7788**). It opens on the **Setup** tab
while Claude Code / Codex still needs a login (the tab shows a **!** badge), otherwise on
**Managers**. Lost the tab? **Ports** panel → `7788` → globe icon, or run `ist-ui url`.

1. **Setup** tab — the **Claude Code** or **Codex CLI** card should say **Ready**; if not,
   log in right there. (The **IST account (detector-agent)** card is optional — it enables
   auto-approval and the web dashboard.)
2. **Managers** tab → **＋ New manager**. (No managers yet? Under the big
   **▶ Start a manager in this folder** button, click **Use another folder**.)
3. In **Start a new manager**, set **Folder (full path)** to
   `/workspaces/ist-codespace/workshops/02-converter-kit/project`.
   Keep the suggested **Name** (e.g. `project-mgr`) or type any name — the prompt works with
   whatever the manager is called. Click **▶ Start**.
4. On the manager's row, click **Copy attach command**, paste it into a VS Code terminal
   (`` Ctrl+` ``) and press Enter — that's the manager's chat.

<details>
<summary>CLI equivalent</summary>

```bash
cd /workspaces/ist-codespace
isesh start project-mgr -w ./workshops/02-converter-kit/project
isesh list          # project-mgr → active
```
</details>

### 3. Paste the manager prompt (1 min)

Copy all of [`project/manager-prompt.md`](project/manager-prompt.md) (everything below the
`---`) and paste it into the manager's terminal (the one you attached with **Copy attach command**; CLI: `isesh attach <manager>`).

### 4. Watch the team work (45–60 min)

Workers are named after your manager — `<manager>` below is its name (e.g. `project-mgr`).

| Phase | Workers | What happens |
|-------|---------|-------------|
| 1 | `<manager>-core` | `Doc` model, format detection, Markdown/text renderers, CLI, README, stub parsers |
| 2 | `<manager>-hwpx` + `<manager>-hwp` (parallel) | HWPX: unzip + XML. HWP: CFB container, raw-deflate streams, binary records, UTF-16 text with control codes |
| 3 | manager (+ you) | Runs everything on your documents, checks the acceptance criteria, routes bugs |

<details>
<summary>CLI monitoring</summary>

```bash
smon watch '<manager>-*' -n <manager> -d     # relay worker state to the manager
ilogsession tail <manager>-hwp         # the binary parser is the most interesting log
isesh list
```
</details>

### 5. Try it on your documents (15 min)

```bash
cd /workspaces/ist-codespace/workshops/02-converter-kit/project
npm run build && npm test
node dist/cli.js info samples/private/*
node dist/cli.js samples/private/* --out-dir out/
```

Open the `.md` files in `out/` (VS Code's Markdown preview: `Ctrl+Shift+V`). Compare the
`.hwp` and `.hwpx` versions of the same document. Something wrong — a missing table,
broken Korean, a heading that isn't one? Tell the manager in plain words and let it route
the fix.

## Try Next

- Ask for a `--images` placeholder mode, or JSON output of the `Doc` model.
- Wrap the library in a tiny web page (drop a file → see Markdown), like Workshop 01's server.
