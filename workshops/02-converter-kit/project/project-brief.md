# hwpconv - Product Specification

## Overview

**hwpconv** converts Korean word-processor documents — **`.hwp` (HWP 5.0)** and
**`.hwpx` (OWPML)** — into **Markdown** and **plain text**. It ships as a Node.js
**library** (`import { convert } from 'hwpconv'`) and a **CLI** (`hwpconv`).

Scope is exactly two input formats: `.hwp` (5.0) and `.hwpx`. Everything else is out of
scope (see the end of this document).

## Target User

Developers and analysts who receive government / enterprise documents as HWP or HWPX
and need their text in a searchable, diff-able, LLM-friendly form — without installing
Hancom Office.

## CLI

```bash
hwpconv report.hwpx                    # Markdown to stdout
hwpconv report.hwp -o report.md        # Markdown to a file
hwpconv report.hwp --format text       # plain text
hwpconv docs/*.hwp* --out-dir out/     # batch: out/<name>.md for each input
hwpconv info report.hwp                # format, version, compressed?, encrypted?, sections, paragraphs, tables
```

- Format is detected from the **file content**, not the extension: CFB magic
  `D0 CF 11 E0 A1 B1 1A E1` → HWP; ZIP magic `PK\x03\x04` with a `mimetype` entry of
  `application/hwp+zip` → HWPX. Anything else → error `unsupported format`.
- Exit codes: `0` ok, `1` conversion error (message on stderr), `2` usage error,
  `3` unsupported or encrypted document.
- Batch mode keeps going after a failed file, reports failures at the end, exits `1` if any failed.

## Library API

```ts
export type OutputFormat = 'markdown' | 'text';
export interface ConvertOptions { format?: OutputFormat }          // default 'markdown'
export function convert(input: Uint8Array, opts?: ConvertOptions): string;
export function detectFormat(input: Uint8Array): 'hwp' | 'hwpx' | 'unknown';

// Intermediate model shared by both parsers and both renderers:
export interface Doc { blocks: Block[] }
export type Block =
  | { kind: 'paragraph'; text: string; headingLevel?: 1 | 2 | 3 | 4 | 5 | 6 }
  | { kind: 'table'; rows: string[][] };                          // cell text, row-major
export function parseHwp(input: Uint8Array): Doc;
export function parseHwpx(input: Uint8Array): Doc;
export function toMarkdown(doc: Doc): string;
export function toText(doc: Doc): string;
```

The **`Doc` model is the contract between workers**: the HWP parser, the HWPX parser and
the renderers are built independently against it.

## Format notes (read before implementing)

Primary reference — Hancom's published specs (free download from Hancom's site, search
"한글 문서 파일 형식"): *HWP 5.0 file format (revision 1.3)* and the OWPML / *HWPML*
documents; HWPX is standardised as **KS X 6101**. Hancom's license for the HWP spec asks
products built from it to state:
"본 제품은 한글과컴퓨터의 한/글 문서 파일(.hwp) 공개 문서를 참고하여 개발하였습니다." —
put that line in the README.

### HWPX (zip + XML) — parse directly

- ZIP container. `mimetype` = `application/hwp+zip`. `Contents/content.hpf` (OPF-style
  manifest + spine) lists the section files in order: `Contents/section0.xml`, `section1.xml`, …
  Fall back to sorting `Contents/section*.xml` numerically if the spine is missing.
- Body: `hs:sec` → `hp:p` (paragraph) → `hp:run` → `hp:t` (text). Inside `hp:t`, `hp:tab`
  → `\t`, `hp:lineBreak` → newline. Ignore runs that are only control/shape objects.
- Tables: `hp:tbl` → `hp:tr` → `hp:tc` → `hp:subList` → `hp:p`… (a table sits inside a
  run of a paragraph; emit it as its own `table` block at that position). `hp:cellSpan`
  `colSpan`/`rowSpan` may be > 1.
- Headings: `hp:p@styleIDRef` → `Contents/header.xml` `hh:style` whose `name` is `개요 N`
  / `engName` is `Outline N` → heading level N (cap at 6). Alternatively `hp:p@paraPrIDRef`
  → `hh:paraPr` → `hh:heading type="OUTLINE" level="L"` → heading level L+1.
- Match elements by **local name + namespace URI**, not by prefix (prefixes vary between writers).

### HWP 5.0 (binary) — CFB + zlib-compressed records

- Compound File Binary (OLE2) container. Streams used: `FileHeader`, `DocInfo`,
  `BodyText/Section0..N`. (`PrvText` = a short UTF-16LE preview — handy for sanity checks, not a source of truth.)
- `FileHeader` (256 bytes): signature `HWP Document File`, version (4 bytes), then a
  properties bitfield: bit 0 = **compressed**, bit 1 = **password-encrypted**, bit 2 =
  **distribution document** (`ViewText/` instead of `BodyText/`, encrypted). Encrypted or
  distribution documents → exit code `3` with a clear message; do not attempt decryption.
- If compressed, `DocInfo` and each `Section` stream are **raw deflate** (no zlib header):
  `zlib.inflateRawSync` from Node's built-in `node:zlib`.
- Each stream is a sequence of **records**. Header = one little-endian uint32:
  `tagId = h & 0x3FF`, `level = (h >> 10) & 0x3FF`, `size = h >>> 20`; if `size == 0xFFF`
  the real size is the next uint32.
- Tags (HWPTAG_BEGIN = 0x10): `PARA_HEADER` 0x42, `PARA_TEXT` 0x43, `CTRL_HEADER` 0x47,
  `LIST_HEADER` 0x48, `TABLE` 0x4D. In `DocInfo`: `PARA_SHAPE` 0x19, `STYLE` 0x1A.
- `PARA_TEXT` is UTF-16LE with embedded control characters (code < 32):
  - **char** controls, 1 code unit: 0, 10 (line break), 13 (paragraph end), 24–31
  - **inline** controls, 8 code units: 4–9, 19, 20 (9 = tab → `\t`)
  - **extended** controls, 8 code units: 1–3, 11, 12, 14–18, 21–23 (11 = drawing/table object
    anchor; the object itself follows as a `CTRL_HEADER`)
  Skip the right number of code units or the text turns to garbage.
- Tables: `CTRL_HEADER` with ctrl id `'tbl '` (stored as a little-endian uint32 of the
  reversed chars), then a `TABLE` record (row/col count), then one `LIST_HEADER` per
  cell followed by that cell's paragraphs (at a deeper `level`). Cell address/span are in
  the `LIST_HEADER` cell properties.
- Headings: the paragraph's style id (in `PARA_HEADER`) → `DocInfo` `STYLE` name
  `개요 N` → level N; or `PARA_SHAPE` outline level. Best-effort.

### Libraries — verified on npm (Oct 2026); pick from these, don't invent others

| Package | Use | License | Notes |
|---------|-----|---------|-------|
| `cfb` 1.2.x | read CFB/OLE2 containers (and write them, for test fixtures) | Apache-2.0 | SheetJS; mature |
| `node:zlib` | `inflateRawSync` for HWP streams | (Node built-in) | no dependency needed |
| `fflate` 0.8.x | unzip HWPX (`unzipSync`), zip fixtures (`zipSync`) | MIT | small, no deps |
| `@xmldom/xmldom` 0.9.x | DOM XML parsing for HWPX (keeps document order + namespaces) | MIT | preferred over order-losing object parsers |
| `commander` 12.x | CLI | MIT | |

Already in `package.json`. Not chosen, but useful **for cross-checking output only** (do not
copy code; respect licenses): `hwp.js` (Apache-2.0, HWP viewer/parser, last release 2022),
`node-hwp` (MIT, alpha), `kordoc` (MIT, HWP/HWPX → Markdown, actively maintained),
`@rhwp/core` (MIT, Rust/WASM parser), Python `pyhwp` / `hwp5txt` (**AGPL-3.0** — reference only).

## Markdown output rules

- One blank line between blocks. Paragraph text is trimmed; empty paragraphs are dropped
  (but never more than one blank line in a row).
- Heading level N → `#`×N + space + text.
- Tables → GitHub-flavoured Markdown table. First row is the header row. Escape `|` as
  `\|`; newlines inside a cell → `<br>`. Merged cells: put the text in the top-left cell and
  leave the cells it covers empty. Ragged rows are padded to the widest row.
- Markdown-special characters at the start of a normal paragraph (`#`, `>`, `-`, `+`,
  `1.`) are escaped so they don't become structure.
- Plain text (`--format text`): paragraphs separated by one newline, tables as
  tab-separated rows, headings as plain lines.

## Sample files

You bring the documents — none are committed here.

1. **Your own**: drop `.hwp`/`.hwpx` files into `samples/private/` (git-ignored).
2. **Public documents**: many Korean public-sector sites publish attachments as HWP / HWPX
   (e.g. notices and forms on government portals). Download a few — include at least one
   with a table and one that uses outline (개요) headings.
3. **Make your own with Hancom Office / Hancom Docs**: write a short document with a
   heading, two paragraphs and a 3×3 table, then save it **twice** — as `.hwp` and as
   `.hwpx`. Same content in both formats is the best possible test pair.
4. **Synthetic fixtures (committed, used by `npm test`)**: tests build tiny documents in
   code — HWPX via `fflate.zipSync` + hand-written XML; HWP via `cfb` (new container,
   `FileHeader` + `DocInfo` + `BodyText/Section0` streams whose records are written by a
   small test helper and compressed with `zlib.deflateRawSync`). This keeps tests
   deterministic and license-clean.

Never commit third-party documents unless their license allows it.

## Architecture

```
hwpconv/
├── src/
│   ├── index.ts            # public API: convert, detectFormat, parseHwp, parseHwpx, toMarkdown, toText
│   ├── cli.ts              # commander CLI (#!/usr/bin/env node)
│   ├── model.ts            # Doc / Block types
│   ├── detect.ts           # magic-byte detection
│   ├── hwpx/               # zip + XML → Doc
│   ├── hwp/                # cfb + records → Doc (header.ts, records.ts, text.ts, table.ts, docinfo.ts)
│   └── render/             # markdown.ts, text.ts
├── test/                   # *.test.ts (node:test), fixtures built in code under test/helpers/
├── samples/private/        # your own documents (git-ignored)
├── package.json            # provided
└── tsconfig.json           # provided
```

Imports between source files use the `.ts` extension (`import { x } from './model.ts'`):
`npm test` runs the TypeScript directly (Node 22.18+), and `npm run build` rewrites them
to `.js` in `dist/`. Use erasable TypeScript only — no `enum`, no `namespace`.

## Tech Stack

- **Language:** TypeScript (ESM), **Runtime:** Node.js 22.18+
- **Build:** `tsc` → `dist/` — **Tests:** `node --test` (built in)
- **Dependencies:** `cfb`, `fflate`, `@xmldom/xmldom`, `commander` (see table above)

## Acceptance Criteria

- [ ] `npm run build` and `npm test` pass with no errors
- [ ] `detectFormat` recognises HWP, HWPX and rejects other files (tests with synthetic inputs)
- [ ] **Paragraphs**: all body text of a document comes out, in document order, across multiple sections, for both formats
- [ ] Korean text is correct (UTF-16LE in HWP, UTF-8 XML in HWPX) — no mojibake, no stray control characters
- [ ] Tabs and line breaks inside paragraphs are preserved
- [ ] **Headings**: outline-style (개요 N) paragraphs become `#`…`######` where detectable; documents without them still convert
- [ ] **Tables** (best-effort): simple tables become GFM tables with the right row/column count; merged cells don't break the table; nested tables degrade to text
- [ ] Encrypted / distribution HWP → exit code 3 with a clear message (no crash, no garbage)
- [ ] Same content saved as `.hwp` and `.hwpx` produces the same Markdown (or differences are documented)
- [ ] `hwpconv info` reports format, version, compressed/encrypted flags and counts
- [ ] Batch mode converts a folder and continues past a bad file
- [ ] README: usage, API, limitations, and the Hancom attribution line

## Out of Scope

- Any other format: HWP 3.x and older, HWPML (`.hml`), DOC/DOCX, PDF, ODT, …
- Writing HWP/HWPX, round-tripping, layout fidelity, fonts/colors
- Images, equations, charts, shapes, footnotes/endnotes, headers/footers, memos, fields (dropping them is fine; a `[image]` placeholder is optional)
- Decrypting password-protected or distribution documents
