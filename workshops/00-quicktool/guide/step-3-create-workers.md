# Step 3: Watch Workers Get Created

**Goal:** Observe the manager creating and coordinating worker sessions.

## What Happens Automatically

After you paste the manager prompt, the manager will:

1. **Read the spec** - It reads `project-brief.md` to understand quicktool
2. **Create worker `mgr-core`** - Runs `isesh start mgr-core -w .`
3. **Send tasks to `mgr-core`** - Uses `imessenger send mgr-core "..."`
4. **Wait for Phase 1 to complete**
5. **Create worker `mgr-commands`** - Runs `isesh start mgr-commands -w .`
6. **Send tasks to `mgr-commands`** - Uses `imessenger send mgr-commands "..."`

## Check Worker Status

Open a separate terminal and run:

```bash
isesh list
```

You should see sessions appearing:
```
mgr          active
mgr-core     active
```

And later:
```
mgr          active
mgr-commands active
```

## You're Just Watching

You don't need to do anything here. The manager creates workers, sends them tasks via `imessenger`, and monitors their progress. This is the TDA (Top-Down Architecture) pattern in action.

Next: [Step 4: Monitor in real-time](step-4-monitor.md) - This is the fun part.
