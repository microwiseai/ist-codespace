# IST Workshop / ist (isesh) trial image
# Base provides Node 22 + npm + git out of the box.
FROM mcr.microsoft.com/devcontainers/javascript-node:22

# --- System deps: tmux is required by the ist session flow ---
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends tmux \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --- Heavy installs baked into the image so Codespaces Prebuild caches them ---
# NOTE: These come from PUBLIC npmjs.org. No token, no private registry, no secret.
#   - @anthropic-ai/claude-code : AI CLI used by the workshop (Claude Code)
#   - @openai/codex             : AI CLI used by the workshop (OpenAI Codex)
#   - @microwiseai/snapshot     : public installer (latest on npmjs.org)
# Run as the non-root `node` user so global installs land in the user's prefix
# and `isesh` / `itda` are on PATH at runtime.
USER node

RUN npm install -g @anthropic-ai/claude-code @openai/codex @microwiseai/snapshot

# `snapshot install @ist/beta` pulls the ist bundle from the PUBLIC snapshot
# registry anonymously (verified: no token required). Baking it here means the
# Prebuild caches it and re-opening a Codespace is fast.
RUN snapshot install @ist/beta

# Sanity: fail the build early if the ist CLI or an AI CLI didn't land.
RUN isesh --version && claude --version && codex --version

# Non-fatal: the IST UI (`ist-ui`, @ist/ist-control-ui) joins the @ist/beta
# snapshot later. Until then this only prints a note — never breaks the build.
RUN ist-ui --version || echo "ist-ui not in snapshot yet"
