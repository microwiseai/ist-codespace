# Build a CLI Tool in 30 Minutes Using AI Agents

Welcome to the IST Workshop. You'll use AI agent sessions to build **quicktool**, a developer utility CLI, without writing code yourself.

## What You'll Learn

- **IST Sessions** - Start and manage AI coding sessions with `isesh`
- **TDA Pattern** - The Manager-Worker pattern where a manager session delegates tasks to worker sessions
- **Monitoring** - `smon` tracks each worker's state (idle, permission requests, exits) and relays it to the manager session; `ilogsession` lets you follow each worker's log as it works

## Prerequisites

- A GitHub account (you're already in a Codespace, so you have this)
- An account for a CLI AI tool (Claude Code or Codex)

## Log In to Your CLI AI Tool

The CLI AI tools come pre-installed in this Codespace, but you need to log in
yourself before the agents can run. Open a terminal and start your tool:

```bash
claude
```

Follow the login prompt (a Claude Max subscription works — no API key required).
You can also run `claude login` directly, or use an API key instead with
`export ANTHROPIC_API_KEY=sk-ant-...`. Other tools work the same way, e.g.
`codex`.

**Optional — auto-approval & web dashboard:** once you link this Codespace to
your IST account with a one-time interactive Google sign-in, `smon` can
auto-approve routine agent prompts and pass everything else to the manager, and
you can watch your sessions live in the web dashboard at https://ism.microwiseai.com:

```bash
detector-agent login
```

## Time

~30 minutes

## Workshop Steps

1. [Explore the project](step-1-explore.md) - Understand what you're building
2. [Start the manager](step-2-start-manager.md) - Launch a TDA manager session
3. [Create workers](step-3-create-workers.md) - Watch the manager delegate work
4. [Monitor progress](step-4-monitor.md) - See agents build in real-time
5. [Review and test](step-5-review-test.md) - Try the finished CLI tool
6. [What's next](step-6-whats-next.md) - Install IST on your own machine

Start with [Step 1: Explore the project](step-1-explore.md).
