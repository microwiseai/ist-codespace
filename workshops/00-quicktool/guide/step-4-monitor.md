# Step 4: Monitor Workers in Real-Time

**Goal:** Watch AI agents write code live. This is the WOW moment.

## Start the Session Monitor

In a separate terminal:

```bash
smon watch 'mgr-*' -n mgr -d
```

This starts `smon` in the background. It tracks the state of every session matching `mgr-*` and relays it to the manager session `mgr` (`-n mgr`): when a worker goes idle, hits a permission request that needs a decision, or exits, the manager is told right away instead of having to poll. `smon` reports to the manager, not to you.

To watch the sessions yourself, tail the worker logs below. If you ran `detector-agent login`, you can also see live session status in the web dashboard at https://ism.microwiseai.com.

## Tail Individual Worker Logs

Want to see exactly what a worker is doing? Open more terminals:

```bash
# Watch the core framework worker
ilogsession tail mgr-core
```

```bash
# Watch the commands worker
ilogsession tail mgr-commands
```

## What You're Seeing

- **File creation** - Workers creating `src/index.ts`, `src/commands/time.ts`, etc.
- **Tool calls** - Each `Write`, `Bash`, and `Read` call appears in the log
- **Build attempts** - Workers running `npm run build` and fixing any errors
- **Test runs** - Workers testing their own code with real commands
- **Communication** - Workers sending `[COMPLETE]` messages back to the manager

This is multiple AI agents working in parallel on the same codebase, coordinated by a manager agent. All from a single prompt you pasted.

## Troubleshooting

If a worker seems stuck:

```bash
# Check if it's still active
isesh list

# Send it a nudge via the manager
imessenger send mgr "Check on mgr-core status"
```

Next: [Step 5: Test what was built](step-5-review-test.md)
