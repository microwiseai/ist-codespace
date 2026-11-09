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
yourself (no keys are baked in). You do it once in the IST UI's **Setup** tab —
log in on the **Claude Code** or **Codex CLI** card until it says **Ready**.
[Step 2](guide/step-2-start-manager.md) walks you through it.

Terminal login (if the IST UI won't open, or you want an API key) and the optional
**IST account (detector-agent)** sign-in for auto-approval and the web dashboard:
see [Log in](../../README.md#log-in) in the root README.

## Time

~30 minutes

## Where things are

- `project/` — the product spec (`project-brief.md`), the manager prompt (`manager-prompt.md`) and the starter config (`package.json`, `tsconfig.json`). This folder is the manager's workspace.
- `guide/` — the step-by-step pages below.

Other workshops: [index](../README.md).

## Workshop Steps

1. [Explore the project](guide/step-1-explore.md) - Understand what you're building
2. [Start the manager](guide/step-2-start-manager.md) - Launch a TDA manager session
3. [Create workers](guide/step-3-create-workers.md) - Watch the manager delegate work
4. [Monitor progress](guide/step-4-monitor.md) - See agents build in real-time
5. [Review and test](guide/step-5-review-test.md) - Try the finished CLI tool
6. [What's next](guide/step-6-whats-next.md) - Install IST on your own machine

Start with [Step 1: Explore the project](guide/step-1-explore.md).
