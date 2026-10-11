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

The IST UI server starts automatically when the Codespace starts (port **7788**). If no IST UI
tab opened (browsers often block the pop-up), run `ist-ui` in a terminal and click the URL it
prints, or **Ports** panel → `7788` → globe icon. It opens on the **Setup** tab
while Claude Code / Codex still needs a login (the tab shows a **!** badge), otherwise on
**Managers**. Lost the tab? Same steps: `ist-ui`, or **Ports** → `7788` → globe icon.

1. **Setup** tab — the **Claude Code** or **Codex CLI** card should say **Ready**; if not,
   log in right there. (The **IST account (detector-agent)** card is optional — it enables
   auto-approval and the web dashboard.)
2. **Managers** tab → **＋ New manager**. (No managers yet? Under the big
   **▶ Start a manager in this folder** button, click **Use another folder**.)
3. In **Start a new manager**, set **Folder (full path)** to
   `/workspaces/ist-codespace/workshops/00-quicktool/project`.
   Keep the suggested **Name** (e.g. `project-mgr`) or type any name — the prompt works with
   whatever the manager is called. Click **▶ Start**.
4. On the manager's row, click **Copy attach command**, paste it into a VS Code terminal
   (`` Ctrl+` ``) and press Enter — that's the manager's chat.

<details>
<summary>CLI equivalent</summary>

```bash
cd /workspaces/ist-codespace
isesh start project-mgr -w ./workshops/00-quicktool/project
```

This starts a new AI session named `project-mgr` (any name works) with the quicktool `project/` folder as its workspace.
</details>

## Give It the Manager Prompt

Open the manager prompt and copy its contents:

```bash
cat workshops/00-quicktool/project/manager-prompt.md
```

Paste the entire contents into the manager session (the terminal you attached in step 4 above). The manager will:

1. Read `project-brief.md` to understand the product
2. Create a worker for the CLI framework (Phase 1)
3. Create a worker for the command implementations (Phase 2)
4. Review and test everything (Phase 3)

You just kick it off. The manager handles the rest.

## Verify It's Running

```bash
isesh list
```

You should see your manager (e.g. `project-mgr`) in the list with status `active` (in the UI's **Managers** tab its row shows **Running**).

Next: [Step 3: Watch workers get created](step-3-create-workers.md)
