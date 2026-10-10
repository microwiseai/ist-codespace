# Step 5: Review and Test

**Goal:** Try the CLI tool that AI agents just built for you.

## Build the Project

```bash
cd project
npm run build
```

## Test Each Command

### Time

```bash
# Show current time
node dist/index.js time

# Convert timezone
node dist/index.js time --from UTC --to KST
```

### JSON

```bash
# Format a file
node dist/index.js json package.json

# Format from stdin
echo '{"key":"value","nested":{"a":1}}' | node dist/index.js json
```

### Encode

```bash
# Base64 encode
node dist/index.js encode --base64 hello

# URL encode
node dist/index.js encode --url "hello world"
```

## What Just Happened

You gave a product spec to a manager AI. It broke the work into phases, created worker AIs, delegated tasks, and coordinated the build. You typed one prompt. Multiple agents built a working CLI tool.

That's the TDA pattern with IST.

Next: [Step 6: What's next](step-6-whats-next.md)
