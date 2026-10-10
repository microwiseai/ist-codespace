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

The IST UI opens in a browser tab when the Codespace starts (port **7788**). Lost the
tab? **Ports** panel → `7788` → globe icon, or run `ist-ui url`.

1. **Setup** tab — confirm your AI CLI is logged in.
2. **Managers** tab → **▶ Start a manager in this folder**.
3. Set the folder to `/workspaces/ist-codespace/workshops/02-converter-kit/project`
   (or **Use another folder** and paste it). Name the manager **`conv`** and start it.

<details>
<summary>CLI equivalent</summary>

```bash
cd /workspaces/ist-codespace
isesh start conv -w ./workshops/02-converter-kit/project
isesh list          # conv → active
```
</details>

### 3. Paste the manager prompt (1 min)

Copy all of [`project/manager-prompt.md`](project/manager-prompt.md) (everything below the
`---`) and paste it into the `conv` session (attach from the UI, or `isesh attach conv`).

### 4. Watch the team work (45–60 min)

| Phase | Workers | What happens |
|-------|---------|-------------|
| 1 | `conv-core` | `Doc` model, format detection, Markdown/text renderers, CLI, README, stub parsers |
| 2 | `conv-hwpx` + `conv-hwp` (parallel) | HWPX: unzip + XML. HWP: CFB container, raw-deflate streams, binary records, UTF-16 text with control codes |
| 3 | manager (+ you) | Runs everything on your documents, checks the acceptance criteria, routes bugs |

<details>
<summary>CLI monitoring</summary>

```bash
smon watch 'conv-*' -n conv -d     # relay worker state to the manager
ilogsession tail conv-hwp          # the binary parser is the most interesting log
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
