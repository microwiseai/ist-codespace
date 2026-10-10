# Step 2: Start the Manager

**Goal:** Launch a TDA manager session that will coordinate the build.

## Log In to Your AI CLI

If you haven't already, authenticate the AI CLI you'll use. **Claude Code:**

```bash
claude login                      # Claude Pro/Max subscription (no API key)
# ...or, with an API key instead:
export ANTHROPIC_API_KEY=sk-ant-...
```

**OpenAI Codex:**

```bash
codex login --device-auth         # ChatGPT plan, device-code sign-in
# ...or, with an API key instead:
printenv OPENAI_API_KEY | codex login --with-api-key
```

(Optional) To enable auto-approval and the web dashboard, run the one-time Google
sign-in: `detector-agent login`.

## Start the Manager Session — in the IST UI

The IST UI opens automatically in a browser tab when the Codespace starts (port
7788). Lost the tab? **Ports** panel → `7788` → globe icon, or run `ist-ui url`.

1. **Setup** tab — check that your AI CLI shows as logged in (fix it there or with `claude login` / `codex login --device-auth`).
2. **Managers** tab → **▶ Start a manager in this folder**.
3. In the dialog, set the folder to the quicktool project:
   `/workspaces/ist-codespace/workshops/00-quicktool/project`
   (or click **Use another folder** and paste it). Name it `mgr` and start it.

<details>
<summary>CLI equivalent (works even if the UI isn't installed yet)</summary>

```bash
cd /workspaces/ist-codespace
isesh start mgr -w ./workshops/00-quicktool/project
```

This starts a new AI session named `mgr` with the quicktool `project/` folder as its workspace.
</details>

## Give It the Manager Prompt

Open the manager prompt and copy its contents:

```bash
cat workshops/00-quicktool/project/manager-prompt.md
```

Paste the entire contents into the manager session. The manager will:

1. Read `project-brief.md` to understand the product
2. Create a worker for the CLI framework (Phase 1)
3. Create a worker for the command implementations (Phase 2)
4. Review and test everything (Phase 3)

You just kick it off. The manager handles the rest.

## Verify It's Running

```bash
isesh list
```

You should see `mgr` in the list with status `active` (it also shows as running in the UI's **Managers** tab).

Next: [Step 3: Watch workers get created](step-3-create-workers.md)
