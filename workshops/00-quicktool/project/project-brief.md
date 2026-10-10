# quicktool - Product Specification

## Overview

**quicktool** is a developer utility CLI that provides everyday convenience commands for time conversion, JSON formatting, and text encoding. It's designed to be the tool you reach for when you need a quick answer without leaving the terminal.

## Target User

Developers who live in the terminal and want fast, no-fuss utilities without searching for online tools or remembering obscure shell one-liners.

## Commands

### 1. `quicktool time`

Show current time and convert between timezones.

**Usage:**
```bash
# Show current local time
quicktool time
# Output: 2026-05-29 14:30:00 UTC

# Convert between timezones
quicktool time --from UTC --to KST
# Output: 2026-05-29 14:30:00 UTC -> 2026-05-29 23:30:00 KST

# Convert a specific time
quicktool time "2026-01-15 09:00" --from EST --to JST
# Output: 2026-01-15 09:00:00 EST -> 2026-01-15 23:00:00 JST
```

### 2. `quicktool json`

Format and validate JSON from stdin or a file.

**Usage:**
```bash
# Format a JSON file
quicktool json package.json
# Output: (pretty-printed JSON)

# Format JSON from stdin
echo '{"name":"quicktool","version":"0.1.0"}' | quicktool json
# Output:
# {
#   "name": "quicktool",
#   "version": "0.1.0"
# }

# Validate JSON (exit code 0 = valid, 1 = invalid)
quicktool json --validate broken.json
# Output: Error: Unexpected token at position 42
```

### 3. `quicktool encode`

Base64 and URL encode/decode strings.

**Usage:**
```bash
# Base64 encode
quicktool encode --base64 "hello world"
# Output: aGVsbG8gd29ybGQ=

# Base64 decode
quicktool encode --base64-decode "aGVsbG8gd29ybGQ="
# Output: hello world

# URL encode
quicktool encode --url "hello world & more"
# Output: hello%20world%20%26%20more

# URL decode
quicktool encode --url-decode "hello%20world"
# Output: hello world
```

## Architecture

```
quicktool/
├── src/
│   ├── index.ts          # Entry point, CLI setup with commander
│   ├── commands/
│   │   ├── time.ts       # Time display and timezone conversion
│   │   ├── json.ts       # JSON formatting and validation
│   │   └── encode.ts     # Base64 and URL encoding/decoding
│   └── utils/
│       └── timezone.ts   # Timezone offset mappings
├── package.json
├── tsconfig.json
└── dist/                 # Compiled output
```

## Tech Stack

- **Language:** TypeScript
- **CLI Framework:** commander (npm package)
- **Runtime:** Node.js 18+
- **Build:** tsc (TypeScript compiler)
- **Dependencies:** typescript, commander, @types/node

## Success Criteria

- [ ] `quicktool time` displays current time accurately
- [ ] `quicktool time --from X --to Y` converts correctly between at least 5 common timezones (UTC, EST, PST, KST, JST)
- [ ] `quicktool json <file>` pretty-prints valid JSON files
- [ ] `quicktool json` reads and formats JSON from stdin
- [ ] `quicktool json --validate` reports errors with position info
- [ ] `quicktool encode --base64` and `--base64-decode` round-trip correctly
- [ ] `quicktool encode --url` and `--url-decode` round-trip correctly
- [ ] All commands show helpful `--help` output
- [ ] Project builds with `npm run build` without errors
