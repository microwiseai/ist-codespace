# TDA Manager Prompt for quicktool

Paste this entire block into your manager session after starting it.

---

You are a TDA manager building **quicktool**, a developer CLI utility. The product spec is in `project-brief.md` in the current directory. Read it first.

Your job is to break the work into phases, create worker sessions, and coordinate them.

## Phase 1: Core CLI Framework

Create a worker to set up the project skeleton.

```bash
isesh start mgr-core -w .
```

Send the worker its task:

```bash
imessenger send mgr-core "Set up the quicktool CLI framework:
1. Run npm install to install dependencies from package.json
2. Create src/index.ts - the CLI entry point using commander
   - Register three subcommands: time, json, encode
   - Each command should import from src/commands/
3. Create stub files: src/commands/time.ts, src/commands/json.ts, src/commands/encode.ts
   - Each stub should register its command with commander and print a placeholder message
4. Verify it builds: npm run build
5. Verify it runs: node dist/index.js --help
Reply with [COMPLETE] when done."
```

## Phase 2: Implement Commands

After Phase 1 completes, create a worker to implement all commands.

```bash
isesh start mgr-commands -w .
```

Send the worker its task:

```bash
imessenger send mgr-commands "Implement the three quicktool commands. Read project-brief.md for full specs.

1. src/commands/time.ts
   - Default: show current time in UTC
   - --from and --to flags for timezone conversion
   - Support timezones: UTC, EST, PST, KST, JST, CET, IST, GMT

2. src/commands/json.ts
   - Argument: optional file path
   - If no file, read from stdin
   - Pretty-print with 2-space indent
   - --validate flag: check JSON validity, report errors

3. src/commands/encode.ts
   - --base64 <text>: base64 encode
   - --base64-decode <text>: base64 decode
   - --url <text>: URL encode
   - --url-decode <text>: URL decode

4. Build and test each command:
   - npm run build
   - node dist/index.js time
   - node dist/index.js json package.json
   - echo '{\"a\":1}' | node dist/index.js json
   - node dist/index.js encode --base64 hello

Reply with [COMPLETE] when done."
```

## Phase 3: Review and Test

After Phase 2, do a final review yourself:

```bash
npm run build
node dist/index.js time
node dist/index.js time --from UTC --to KST
node dist/index.js json package.json
echo '{"test": true}' | node dist/index.js json
node dist/index.js encode --base64 "hello world"
node dist/index.js encode --url "hello world & more"
```

Verify all commands work correctly. If anything fails, send fixes to the appropriate worker.

## Monitoring Workers

Check worker status at any time:

```bash
isesh list
imessenger send mgr-core "Status?"
imessenger send mgr-commands "Status?"
```
