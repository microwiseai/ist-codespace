# Step 1: Explore the Project

**Goal:** Understand what you're building before the AI agents start working.

## Read the Product Spec

```bash
cd project
cat project-brief.md
```

This is the spec for **quicktool**, a CLI with three commands:

| Command | What it does |
|---------|-------------|
| `quicktool time` | Show current time, convert between timezones |
| `quicktool json` | Pretty-print and validate JSON |
| `quicktool encode` | Base64 and URL encode/decode |

## Check the Starter Files

```bash
ls project/
```

You'll see:
- `project-brief.md` - The full product specification
- `manager-prompt.md` - The prompt you'll give to the manager AI
- `package.json` - Node.js project with TypeScript and commander
- `tsconfig.json` - TypeScript configuration

No source code yet. The AI agents will write it all.

## What to Expect

In the next steps, you'll:
1. Start a **manager** AI session
2. The manager reads the spec and creates **worker** sessions
3. Workers write the code in parallel
4. You monitor everything in real-time
5. You test the finished tool

You won't write any code. You'll orchestrate AI agents and watch them build.

Next: [Step 2: Start the manager](step-2-start-manager.md)
