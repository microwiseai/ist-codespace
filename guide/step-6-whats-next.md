# Step 6: What's Next

## Install IST on Your Machine

Take IST beyond Codespaces. Install it locally the same way this Codespace image does.

Prerequisites: tmux, Node.js/npm, and Claude Code (`npm install -g @anthropic-ai/claude-code`).

```bash
npm install -g @microwiseai/snapshot
snapshot install @ist/beta
```

This installs the full IST toolkit: `isesh`, `imessenger`, `smon`, `ilogsession`, and more.

Check that it landed:

```bash
isesh --version
```

For installation details, see the [installation guide](https://docs.ist.microwiseai.com/docs/installation/).

## Try With Your Own Project

The same pattern works for any project:

1. Write a product spec (like `project-brief.md`)
2. Write a manager prompt that breaks work into phases
3. Start a manager session and paste the prompt
4. Monitor and test

## Key IST Commands You Learned

| Command | Purpose |
|---------|---------|
| `isesh start <name>` | Start a new AI session |
| `isesh list` | List active sessions |
| `imessenger send <name> "..."` | Send a message to a session |
| `smon watch '<pattern>'` | Monitor sessions live |
| `ilogsession tail <name>` | Stream a session's log |

## Resources

- **IST Documentation:** [docs.ist.microwiseai.com](https://docs.ist.microwiseai.com/)
- **Feedback & questions:** [github.com/microwiseai/feedback](https://github.com/microwiseai/feedback) — Discussions (questions & ideas) / Issues (bugs)

Thanks for completing the workshop!
