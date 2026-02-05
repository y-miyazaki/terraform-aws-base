#!/bin/bash
# Simple devcontainer initialization script
# Responsibilities:
#  - Fix ownership for mounted config dirs
#  - Install pre-commit hook (if available)
#  - Prepare terraform plugin cache
#  - Configure git credential helper for GitHub (HTTPS) using gh

set -eu

# aqua lazy install
if command -v aqua > /dev/null 2>&1; then
    aqua i -l || echo "[warn] aqua lazy install failed" >&2
fi

# Adjust ownership (only if paths exist)
if [ -e /home/vscode/.aws ]; then sudo chown -R "$(id -u)":"$(id -g)" /home/vscode/.aws || true; fi
if [ -e /home/vscode/.gitconfig ]; then sudo chown -R "$(id -u)":"$(id -g)" /home/vscode/.gitconfig || true; fi
if [ -e /home/vscode/.ssh ]; then sudo chown -R "$(id -u)":"$(id -g)" /home/vscode/.ssh || true; fi
chmod 600 /home/vscode/.ssh/id_* 2> /dev/null || true

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
