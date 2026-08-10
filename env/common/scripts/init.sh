#!/bin/bash
#######################################
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
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
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
# Cursor CLI statusline (~/.config/cursor/cli-config.json — agent reads this path)
#######################################
if [ -f "${repo_root}/.cursor/statusline.sh" ]; then
    mkdir -p ~/.cursor
    cp -p "${repo_root}/.cursor/statusline.sh" ~/.cursor/statusline.sh
    chmod +x ~/.cursor/statusline.sh

    if command -v jq > /dev/null 2>&1; then
        statusline_json="{\"command\":\"${HOME}/.cursor/statusline.sh\",\"padding\":2,\"timeoutMs\":5000,\"type\":\"command\",\"updateIntervalMs\":500}"
        for cli_config in "${HOME}/.config/cursor/cli-config.json" "${HOME}/.cursor/cli-config.json"; do
            mkdir -p "$(dirname "${cli_config}")"
            if [ -f "${cli_config}" ]; then
                jq --argjson sl "${statusline_json}" '.statusLine = $sl | .version = (.version // 1)' "${cli_config}" > "${cli_config}.tmp" \
                    && mv "${cli_config}.tmp" "${cli_config}"
            else
                jq -n --argjson sl "${statusline_json}" \
                    '{version: 1, editor: {vimMode: false}, permissions: {allow: ["Shell(ls)"], deny: []}, statusLine: $sl}' \
                    > "${cli_config}"
            fi
        done
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
        )
    fi
fi

#######################################
# lean-ctx (after apm install — project MCP via APM, user MCP suppressed)
#
# Project MCP: APM → /workspace/.cursor/mcp.json (lean-ctx in common apm.yml).
# User MCP (~/.cursor/mcp.json): suppress via setup.auto_update_mcp=false (GH #281).
#   Global: ~/.config/lean-ctx/config.toml — pre-seed below before lean-ctx trust.
#   Project: .lean-ctx.toml [setup] — override; lean-ctx trust applies trust-gated keys.
# Shell/hooks: lean-ctx setup writes env/common/.bashrc (bind-mounted as ~/.bashrc).
# Do not run: lean-ctx wrap cursor (re-adds user-scope ~/.cursor/mcp.json).
# mise install only places lean-ctx-bin on PATH; it does not run lean-ctx setup.
#######################################
if command -v lean-ctx > /dev/null 2>&1 || command -v npx > /dev/null 2>&1; then
    mkdir -p "${HOME}/.config/lean-ctx"
    if [ ! -f "${HOME}/.config/lean-ctx/config.toml" ]; then
        cat > "${HOME}/.config/lean-ctx/config.toml" << 'EOF'
[setup]
auto_update_mcp = false
auto_inject_rules = false
auto_inject_skills = false
EOF
    elif ! grep -q 'auto_update_mcp' "${HOME}/.config/lean-ctx/config.toml" 2> /dev/null; then
        printf '\n[setup]\nauto_update_mcp = false\nauto_inject_rules = false\nauto_inject_skills = false\n' \
            >> "${HOME}/.config/lean-ctx/config.toml"
    fi

    (
        cd "$repo_root"
        if command -v lean-ctx > /dev/null 2>&1; then
            lean-ctx trust || echo "[warn] lean-ctx trust failed" >&2
        else
            npx -y lean-ctx-bin@3.9.13 trust || echo "[warn] lean-ctx trust failed" >&2
        fi
    )
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
