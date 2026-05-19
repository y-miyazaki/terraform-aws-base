#!/bin/bash
# Simple devcontainer initialization script
# Responsibilities:
#  - Ensure local data directories are writable for user-level tools like aqua
#  - Perform lazy installation for aqua and apm (if available)
#  - Adjust ownership for common config directories (e.g., .aws, .gitconfig, .local, .ssh)
#  - Install pre-commit hooks (if pre-commit is available)
#  - Set up GitHub credential helper for repositories with GitHub remotes (if gh is available)
set -eu

# Adjust ownership (only if paths exist)
if [ -e /home/vscode/.aws ]; then sudo chown -R "$(id -u)":"$(id -g)" /home/vscode/.aws || true; fi
if [ -e /home/vscode/.gitconfig ]; then sudo chown -R "$(id -u)":"$(id -g)" /home/vscode/.gitconfig || true; fi
if [ -e /home/vscode/.local ]; then sudo chown -R "$(id -u)":"$(id -g)" /home/vscode/.local || true; fi
if [ -e /home/vscode/.ssh ]; then sudo chown -R "$(id -u)":"$(id -g)" /home/vscode/.ssh || true; fi
chmod 600 /home/vscode/.ssh/id_* 2> /dev/null || true

# aqua data directory
mkdir -p "$HOME/.local/share/aquaproj-aqua" 2> /dev/null || true
# aqua lazy install
if command -v aqua > /dev/null 2>&1; then
    aqua i -l || echo "[warn] aqua lazy install failed" >&2
    aqua policy allow /workspace/aqua-policy.yaml 2> /dev/null || echo "[warn] aqua policy apply failed" >&2
fi

# apm install (optional)
if command -v apm > /dev/null 2>&1; then
    apm install || echo "[warn] apm install failed" >&2
fi

# pre-commit (optional)
if command -v pre-commit > /dev/null 2>&1; then
    pre-commit install || echo "[warn] pre-commit install failed" >&2
fi

# terraform cache & version
mkdir -p "$HOME/.terraform.d/plugin-cache"

# GitHub credential helper (simple)
if command -v git > /dev/null 2>&1; then
    repo_root=$(git rev-parse --show-toplevel 2> /dev/null || true)
    if [ -n "${repo_root}" ]; then
        origin_url=$(git -C "$repo_root" remote get-url origin 2> /dev/null || true)
        if echo "$origin_url" | grep -Eq '^https://github.com/' && command -v gh > /dev/null 2>&1; then
            git -C "$repo_root" config --local --unset-all credential.helper 2> /dev/null || true
            git -C "$repo_root" config --local credential.helper ''
            git -C "$repo_root" config --local --add credential.helper '!gh auth git-credential'
            [ -n "${GIT_USER_NAME:-}" ] && git -C "$repo_root" config --local user.name "$GIT_USER_NAME"
            [ -n "${GIT_USER_EMAIL:-}" ] && git -C "$repo_root" config --local user.email "$GIT_USER_EMAIL"
        fi
    fi
fi

# for GitHub Copilot CLI setup
if command -v copilot > /dev/null 2>&1; then
    if [ -n "${COPILOT_BASE:-}" ] && [ -d "$COPILOT_BASE/config/.copilot" ]; then
        cp -rp /workspace/.vscode/mcp-example-config.json "$COPILOT_BASE/config/.copilot/mcp-config.json" || true
    fi
fi
exit 0
