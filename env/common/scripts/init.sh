#!/bin/bash
# Simple devcontainer initialization script
# Responsibilities:
#  - Ensure local data directories are writable for user-level tools like aqua
#  - Perform lazy installation for aqua and apm (if available)
#  - Adjust ownership for common config directories (e.g., .aws, .gitconfig, .local, .ssh)
#  - Install pre-commit hooks (if pre-commit is available)
#  - Set up GitHub credential helper for repositories with GitHub remotes (if gh is available)
set -euo pipefail

uid="$(id -u)"
gid="$(id -g)"
repo_root=""

if command -v git > /dev/null 2>&1; then
    if git -C /workspace rev-parse --show-toplevel > /dev/null 2>&1; then
        repo_root="$(git -C /workspace rev-parse --show-toplevel 2> /dev/null || true)"
    else
        repo_root="$(git rev-parse --show-toplevel 2> /dev/null || true)"
    fi
fi

# Adjust ownership (only if paths exist)
if [ -e "$HOME/.aws" ]; then sudo chown -R "$uid":"$gid" "$HOME/.aws" || true; fi
if [ -e "$HOME/.gitconfig" ]; then sudo chown -R "$uid":"$gid" "$HOME/.gitconfig" || true; fi
if [ -e "$HOME/.local" ]; then sudo chown -R "$uid":"$gid" "$HOME/.local" || true; fi
if [ -e "$HOME/.ssh" ]; then sudo chown -R "$uid":"$gid" "$HOME/.ssh" || true; fi
chmod 600 "$HOME/.ssh"/id_* 2> /dev/null || true

# aqua data directory
mkdir -p "$HOME/.local/share/aquaproj-aqua" 2> /dev/null || true
# aqua lazy install
if command -v aqua > /dev/null 2>&1; then
    aqua i -l || echo "[warn] aqua lazy install failed" >&2
    aqua policy allow /workspace/aqua-policy.yaml 2> /dev/null || echo "[warn] aqua policy apply failed" >&2
fi

# apm install (optional)
if command -v apm > /dev/null 2>&1; then
    apm install --frozen || echo "[warn] apm install failed" >&2
fi

# pre-commit (optional)
if command -v pre-commit > /dev/null 2>&1; then
    if [ -n "${repo_root}" ]; then
        (
            cd "$repo_root"
            pre-commit install
        ) || echo "[warn] pre-commit install failed" >&2
    fi
fi

# terraform cache & version
mkdir -p "$HOME/.terraform.d/plugin-cache"

# GitHub credential helper (simple)
if command -v git > /dev/null 2>&1 && [ -n "${repo_root}" ]; then
    origin_url=$(git -C "$repo_root" remote get-url origin 2> /dev/null || true)
    if echo "$origin_url" | grep -Eq '^https://github.com/' && command -v gh > /dev/null 2>&1; then
        git -C "$repo_root" config --local --unset-all credential.helper 2> /dev/null || true
        git -C "$repo_root" config --local credential.helper ''
        git -C "$repo_root" config --local --add credential.helper '!gh auth git-credential'
        [ -n "${GIT_USER_NAME:-}" ] && git -C "$repo_root" config --local user.name "$GIT_USER_NAME"
        [ -n "${GIT_USER_EMAIL:-}" ] && git -C "$repo_root" config --local user.email "$GIT_USER_EMAIL"
    fi
fi

exit 0
