# IST Workshop / ist (isesh) trial image
# Recipe for the published image, built and tested locally. Codespaces pull that
# image by digest and never build this file. To update, change the pinned versions
# here and follow "Updating the Image" in the README.
# Base provides Node 22 + npm + git out of the box.
FROM mcr.microsoft.com/devcontainers/javascript-node:22

# --- System deps: tmux is required by the ist session flow ---
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends tmux \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --- Heavy installs baked into the image ---
# NOTE: These come from PUBLIC npmjs.org. No token, no private registry, no secret.
#   - @anthropic-ai/claude-code : AI CLI used by the workshop (Claude Code)
#   - @openai/codex             : AI CLI used by the workshop (OpenAI Codex)
#   - @microwiseai/snapshot     : public installer
#   - @glpkg/cli                : public installer for the IST UI package (below)
# Run as the non-root `node` user so global installs land in the user's prefix
# and `isesh` / `itda` are on PATH at runtime.
USER node

RUN npm install -g \
    @anthropic-ai/claude-code@2.1.317 \
    @openai/codex@0.166.0 \
    @microwiseai/snapshot@0.8.0 \
    @glpkg/cli@0.16.1

# `snapshot install @ist/beta@<version>` pulls the ist bundle from the PUBLIC
# snapshot registry anonymously (verified: no token required).
# The output is kept in the image: the install ledger only lists packages that
# succeeded, so smoke-test.sh reads this log to catch partial failures
# ("Installed: N/M", "Failed:") even if the CLI ever exits 0 on them.
RUN mkdir -p /home/node/.cache/ist-codespace \
    && bash -o pipefail -c 'snapshot install @ist/beta@0.3.0 2>&1 | tee /home/node/.cache/ist-codespace/snapshot-install.log'

# The IST UI (`ist-ui`, port 7788): public, no token needed. glpkg resolves the
# registry itself — no .npmrc is written here.
RUN glpkg install -g @ist/ist-control-ui@0.3.0 --group microwiseai

# Sanity: fail the build early if the ist CLI, an AI CLI or the UI didn't land.
RUN isesh --version && claude --version && codex --version && ist-ui --version
