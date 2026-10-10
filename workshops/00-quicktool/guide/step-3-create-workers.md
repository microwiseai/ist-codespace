# Step 3: Watch Workers Get Created

**Goal:** Observe the manager creating and coordinating worker sessions.

## What Happens Automatically

Workers are named after the manager: `<manager>-core`, `<manager>-commands`. Below we
assume the manager is `project-mgr` (the UI's suggested name).

After you paste the manager prompt, the manager will:

1. **Read the spec** - It reads `project-brief.md` to understand quicktool
2. **Create worker `project-mgr-core`** - Runs `isesh start project-mgr-core -w . --state manager=project-mgr`
3. **Send tasks to `project-mgr-core`** - Uses `imessenger send project-mgr-core "..."`
4. **Wait for Phase 1 to complete**
5. **Create worker `project-mgr-commands`** - Runs `isesh start project-mgr-commands -w . --state manager=project-mgr`
6. **Send tasks to `project-mgr-commands`** - Uses `imessenger send project-mgr-commands "..."`

## Check Worker Status

Open a separate terminal and run:

```bash
isesh list
```

You should see sessions appearing:
```
project-mgr          active
project-mgr-core     active
```

And later:
```
project-mgr          active
project-mgr-commands active
```

## You're Just Watching

`--state manager=project-mgr` is what makes the workers show up under the manager in the IST UI's **Managers** tab. You don't need to do anything here. The manager creates workers, sends them tasks via `imessenger`, and monitors their progress. This is the TDA (Top-Down Architecture) pattern in action.

Next: [Step 4: Monitor in real-time](step-4-monitor.md) - This is the fun part.
