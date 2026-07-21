#!/bin/bash
# Simple devcontainer initialization script
# Responsibilities:
#  - Adjust ownership for common config directories (e.g., .aws, .gitconfig, .local, .ssh)
#  - Run apm install (if apm is available)
#  - Perform lazy installation for aqua and apply aqua policy (if aqua is available)
#  - Install gh extensions (if gh is available)
#  - Apply mise trust and run mise install (if mise is available and mise.toml exists)
#  - Install pre-commit hooks (if pre-commit is available)
#  - Create Terraform plugin cache directory
#  - Set up GitHub credential helper for repositories with GitHub remotes (if gh is available)
set -euo pipefail

# Workspace root (resolved from devcontainer env; falls back to /workspace)
WORKSPACE="${CONTAINER_WORKSPACE_FOLDER:-/workspace}"

uid="$(id -u)"
gid="$(id -g)"
repo_root=""

if command -v git > /dev/null 2>&1; then
    if git -C "${WORKSPACE}" rev-parse --show-toplevel > /dev/null 2>&1; then
        repo_root="$(git -C "${WORKSPACE}" rev-parse --show-toplevel 2> /dev/null || true)"
    else
        repo_root="$(git rev-parse --show-toplevel 2> /dev/null || true)"
    fi
fi

if [ -z "${repo_root}" ]; then
    repo_root="${WORKSPACE}"
fi

#######################################
# Adjust ownership (only if paths exist)
#######################################
if [ -e "$HOME/.aws" ]; then sudo chown -R "$uid":"$gid" "$HOME/.aws" || true; fi
if [ -e "$HOME/.gitconfig" ]; then sudo chown -R "$uid":"$gid" "$HOME/.gitconfig" || true; fi
if [ -e "$HOME/.local" ]; then sudo chown -R "$uid":"$gid" "$HOME/.local" || true; fi
if [ -e "$HOME/.ssh" ]; then sudo chown -R "$uid":"$gid" "$HOME/.ssh" || true; fi
chmod 600 "$HOME/.ssh"/id_* 2> /dev/null || true

#######################################
# Claude (optional)
#######################################
if command -v claude > /dev/null 2>&1; then
    if [ -f "${repo_root}/.claude/scripts/statusline.sh" ]; then
        mkdir -p ~/.claude
        cp -rp "${repo_root}/.claude/scripts/statusline.sh" ~/.claude/
    fi
fi

#######################################
# Cursor CLI statusline (optional; config lives in ~/.cursor/cli-config.json)
#######################################
if [ -f "${repo_root}/.cursor/statusline.sh" ]; then
    mkdir -p ~/.cursor
    cp -p "${repo_root}/.cursor/statusline.sh" ~/.cursor/statusline.sh
    chmod +x ~/.cursor/statusline.sh

    if command -v jq > /dev/null 2>&1; then
        statusline_json="{\"command\":\"${HOME}/.cursor/statusline.sh\",\"padding\":2,\"timeoutMs\":5000,\"type\":\"command\",\"updateIntervalMs\":500}"
        cli_config="${HOME}/.cursor/cli-config.json"
        if [ -f "${cli_config}" ]; then
            jq --argjson sl "${statusline_json}" '.statusLine = $sl | .version = (.version // 1)' "${cli_config}" > "${cli_config}.tmp" \
                && mv "${cli_config}.tmp" "${cli_config}"
        else
            jq -n --argjson sl "${statusline_json}" \
                '{version: 1, editor: {vimMode: false}, permissions: {allow: ["Shell(ls)"], deny: []}, statusLine: $sl}' \
                > "${cli_config}"
        fi
    fi
fi

#######################################
# mise trust (optional)
#######################################
if command -v mise > /dev/null 2>&1; then
    if [ -f "${repo_root}/mise.toml" ]; then
        (
            cd "$repo_root"
            mise trust --yes "${repo_root}/mise.toml" > /dev/null 2>&1 || echo "[warn] mise trust failed" >&2
            mise install || echo "[warn] mise install task failed" >&2
            mise reshim --yes || echo "[warn] mise reshim failed" >&2
            mise prune --yes || echo "[warn] mise prune failed" >&2
            # Expose mise shims on PATH for login shells that do not source .bashrc (e.g. zsh).
            # Cursor hooks inherit PATH from remoteEnv in devcontainer.json, not from profile.d.
            mise_shims="${HOME}/.local/share/mise/shims"
            if [ -d "${mise_shims}" ]; then
                printf '%s\n' \
                    '# mise shims on PATH (devcontainer; see .devcontainer/devcontainer.json remoteEnv)' \
                    "export PATH=\"${mise_shims}:\$PATH\"" \
                    | sudo tee /etc/profile.d/mise-shims.sh > /dev/null
                sudo chmod 644 /etc/profile.d/mise-shims.sh
            fi
        )
    fi
fi

#######################################
# apm install (optional)
#######################################
if command -v apm > /dev/null 2>&1; then
    # apm.yml is expected to be in the workspace root; if it doesn't exist, apm install will still work but with no packages
    if [ -f "${repo_root}/apm.yml" ]; then
        (
            cd "$repo_root"
            apm install --frozen || echo "[warn] apm install failed" >&2
            apm run postinstall || echo "[warn] apm run failed" >&2
        )
    fi
fi

#######################################
# lean-ctx MCP scope (workspace via APM is canonical)
#######################################
if command -v lean-ctx > /dev/null 2>&1; then
    mkdir -p "${HOME}/.config/lean-ctx"
    lean-ctx config set setup.auto_update_mcp false > /dev/null 2>&1 \
        || echo "[warn] lean-ctx config set (auto_update_mcp) failed" >&2
    lean-ctx trust || echo "[warn] lean trust failed" >&2
fi

#######################################
# aqua lazy install (optional)
#######################################
if command -v aqua > /dev/null 2>&1; then
    # aqua.yaml is expected to be in the workspace root; if it doesn't exist, lazy install will still work but policy application will be skipped
    if [ -f "${repo_root}/aqua.yaml" ]; then
        (
            cd "$repo_root"
            mkdir -p "$HOME/.local/share/aquaproj-aqua" 2> /dev/null || true
            aqua i -l || echo "[warn] aqua lazy install failed" >&2
            aqua policy allow "${repo_root}/aqua-policy.yaml" 2> /dev/null || echo "[warn] aqua policy apply failed" >&2
        )
    fi
fi

#######################################
# gh extension install (optional)
#######################################
if command -v gh > /dev/null 2>&1; then
    if ! gh extension list 2> /dev/null | grep -q "github/gh-aw"; then
        gh extension install github/gh-aw || echo "[warn] gh extension install failed" >&2
    fi
fi

#######################################
# pre-commit (optional)
#######################################
if command -v pre-commit > /dev/null 2>&1; then
    if [ -f "${repo_root}/.pre-commit-config.yaml" ]; then
        (
            cd "$repo_root"
            pre-commit install
            pre-commit install --hook-type commit-msg
        ) || echo "[warn] pre-commit install failed" >&2
    fi
fi

#######################################
# terraform (optional)
#######################################
mkdir -p "$HOME/.terraform.d/plugin-cache"

if command -v tflint > /dev/null 2>&1; then
    # tflint repository initialization (optional)
    if [ -f "${repo_root}/.tflint.hcl" ]; then
        (
            cd "$repo_root"
            tflint --init || echo "[warn] tflint init failed" >&2
        )
    fi
fi

#######################################
# GitHub credential helper (simple)
#######################################
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

#######################################
# Codebase Memory MCP indexing (optional)
#######################################
if command -v codebase-memory-mcp > /dev/null 2>&1; then
    codebase-memory-mcp cli index_repository '{"repo_path": "'"${repo_root}"'"}' || echo "[warn] codebase-memory-mcp indexing failed" >&2
    codebase-memory-mcp config set auto_index true
    codebase-memory-mcp config set auto_index_limit 50000
fi

exit 0
