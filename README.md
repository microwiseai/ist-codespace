# IST Workshop: Build a CLI Tool with AI Agents

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/microwiseai/ist-codespace?quickstart=1)

Build a working CLI tool in 30 minutes without writing code. Use AI agent sessions to go from product spec to finished tool.

## What You'll Learn

- Start and manage AI coding sessions with IST
- Use the TDA (Top-Down Architecture) manager-worker pattern
- Monitor multiple AI agents building code in real-time
- Go from product spec to working software with one prompt

## Prerequisites

- A GitHub account
- A way to authenticate the Claude CLI — **either** a Claude Pro/Max subscription (`claude login`) **or** an [Anthropic API key](https://console.anthropic.com/)

## Quick Start

1. Click the **Open in GitHub Codespaces** badge above
2. Log in to the Claude CLI — **either** `claude login` (Pro/Max) **or** `export ANTHROPIC_API_KEY=sk-ant-...`
3. (Optional, for live monitoring / auto-approval) run `detector-agent login` once — an interactive Google sign-in
4. Follow the [workshop guide](guide/README.md)

> The `isesh` toolchain, `snapshot`, and `claude-code` are **pre-installed in the
> Codespace image** — no tokens or private registries are used. Enable
> [Prebuilds](#speeding-up-with-prebuilds) so re-opening is fast.

## What Gets Built

**quicktool** - a developer utility CLI with three commands:

```bash
quicktool time --from UTC --to KST     # Timezone conversion
quicktool json package.json             # JSON formatting
quicktool encode --base64 hello         # Base64/URL encoding
```

## How It Works

You paste a manager prompt into an AI session. The manager:
1. Reads the product spec
2. Creates worker sessions for each phase
3. Workers write code in parallel
4. You monitor everything live

No code writing. Just orchestration.

## Speeding Up with Prebuilds

The devcontainer bakes the whole toolchain into the image, so a **Codespaces
Prebuild** makes every "Open in Codespaces" fast. Repo/org owner, one time:

1. Go to the repo on GitHub → **Settings → Codespaces → Prebuilds → Set up prebuild**
   (org-wide: **Org Settings → Codespaces → Prebuilds**).
2. Pick this repository and the branch (e.g. `main`).
3. Choose region(s) near your users, then save.

GitHub builds the image ahead of time and refreshes it on pushes that change
`.devcontainer/**`. After the first prebuild, opening a Codespace uses the cache.

## Project Structure

```
guide/          # Step-by-step workshop instructions
project/        # Product spec, manager prompt, and starter config
.devcontainer/  # Codespace config — Dockerfile prebakes isesh/snapshot/claude-code
```

