#!/bin/bash
#######################################
# Description:
#   Step functions shared by the devcontainer lifecycle scripts (sourced, never executed).
#   Each step is optional: it returns 0 without doing anything when its tool or input file is
#   missing, and a failing tool prints "[warn] ..." to stderr without stopping later steps.
#
# Design Rules:
#   - Sourced library: no set -euo pipefail, no main, no entry guard.
#   - The lifecycle scripts own ordering; this file only defines the steps.
#   - REPO_ROOT is set by the caller (resolve_repo_root prints it).
#
# Used by:
#   on_create.sh, update_content.sh, post_create.sh, post_start.sh
#######################################

# Workspace root (resolved from devcontainer env; falls back to /workspace)
WORKSPACE="${CONTAINER_WORKSPACE_FOLDER:-/workspace}"

# Repository root; set by the calling lifecycle script
REPO_ROOT=""

#######################################
# adjust_ownership: Give the current user ownership of common config paths that exist
#
# Globals:
#   HOME - Home directory holding the config paths
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0
#######################################
function adjust_ownership {
    local uid gid path
    uid="$(id -u)"
    gid="$(id -g)"

    for path in "${HOME}/.aws" "${HOME}/.claude" "${HOME}/.gitconfig" "${HOME}/.local" "${HOME}/.ssh"; do
        if [[ -e ${path} ]]; then
            sudo chown -R "${uid}":"${gid}" "${path}" || true
        fi
    done
    chmod 600 "${HOME}/.ssh"/id_* 2> /dev/null || true
}

#######################################
# configure_claude_statusline: Copy the Claude statusline script into ~/.claude
#
# Globals:
#   HOME      - Home directory receiving the copy
#   REPO_ROOT - Repository root holding .claude/scripts/statusline.sh
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0
#######################################
function configure_claude_statusline {
    command -v claude > /dev/null 2>&1 || return 0
    if [[ -f ${REPO_ROOT}/.claude/scripts/statusline.sh ]]; then
        mkdir -p "${HOME}/.claude"
        cp -rp "${REPO_ROOT}/.claude/scripts/statusline.sh" "${HOME}/.claude/"
    fi
}

#######################################
# configure_cursor_statusline: Install the Cursor CLI statusline and register it in the CLI config
#
# Description:
#   The Cursor agent reads ~/.config/cursor/cli-config.json (and ~/.cursor/cli-config.json).
#
# Globals:
#   HOME      - Home directory receiving the script and config
#   REPO_ROOT - Repository root holding .cursor/statusline.sh
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0
#######################################
function configure_cursor_statusline {
    local statusline_json cli_config
    [[ -f ${REPO_ROOT}/.cursor/statusline.sh ]] || return 0

    mkdir -p "${HOME}/.cursor"
    cp -p "${REPO_ROOT}/.cursor/statusline.sh" "${HOME}/.cursor/statusline.sh"
    chmod +x "${HOME}/.cursor/statusline.sh"

    command -v jq > /dev/null 2>&1 || return 0
    statusline_json="{\"command\":\"${HOME}/.cursor/statusline.sh\",\"padding\":2,\"timeoutMs\":5000,\"type\":\"command\",\"updateIntervalMs\":500}"
    for cli_config in "${HOME}/.config/cursor/cli-config.json" "${HOME}/.cursor/cli-config.json"; do
        mkdir -p "$(dirname "${cli_config}")"
        if [[ -f ${cli_config} ]]; then
            jq --argjson sl "${statusline_json}" '.statusLine = $sl | .version = (.version // 1)' "${cli_config}" > "${cli_config}.tmp" \
                && mv "${cli_config}.tmp" "${cli_config}"
        else
            jq -n --argjson sl "${statusline_json}" \
                '{version: 1, editor: {vimMode: false}, permissions: {allow: ["Shell(ls)"], deny: []}, statusLine: $sl}' \
                > "${cli_config}"
        fi
    done
}

#######################################
# configure_github_credentials: Use the gh credential helper for repositories with a GitHub remote
#
# Globals:
#   GIT_USER_EMAIL - Optional git user.email for the repository
#   GIT_USER_NAME  - Optional git user.name for the repository
#   REPO_ROOT      - Repository root whose local git config is changed
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0
#######################################
function configure_github_credentials {
    local origin_url
    command -v git > /dev/null 2>&1 || return 0
    [[ -n ${REPO_ROOT} ]] || return 0

    origin_url="$(git -C "${REPO_ROOT}" remote get-url origin 2> /dev/null || true)"
    if echo "${origin_url}" | grep -Eq '^https://github.com/' && command -v gh > /dev/null 2>&1; then
        git -C "${REPO_ROOT}" config --local --unset-all credential.helper 2> /dev/null || true
        git -C "${REPO_ROOT}" config --local credential.helper ''
        git -C "${REPO_ROOT}" config --local --add credential.helper '!gh auth git-credential'
        if [[ -n ${GIT_USER_NAME:-} ]]; then
            git -C "${REPO_ROOT}" config --local user.name "${GIT_USER_NAME}"
        fi
        if [[ -n ${GIT_USER_EMAIL:-} ]]; then
            git -C "${REPO_ROOT}" config --local user.email "${GIT_USER_EMAIL}"
        fi
    fi
}

#######################################
# index_codebase_memory: Index the repository with codebase-memory-mcp and enable auto-index
#
# Globals:
#   REPO_ROOT - Repository root to index
#
# Arguments:
#   None
#
# Outputs:
#   See index_repository_root
#
# Returns:
#   0
#######################################
function index_codebase_memory {
    command -v codebase-memory-mcp > /dev/null 2>&1 || return 0
    command -v jq > /dev/null 2>&1 || return 0
    [[ -n ${REPO_ROOT} ]] || return 0

    index_repository_root "${REPO_ROOT}"
    codebase-memory-mcp config set auto_index true
    codebase-memory-mcp config set auto_index_limit 50000
}

#######################################
# index_project: Index one path as a named project
#
# Globals:
#   None
#
# Arguments:
#   $1 - Directory to index
#   $2 - Project name (empty lets the tool choose)
#
# Outputs:
#   Tool output on stdout and stderr
#
# Returns:
#   The exit status of codebase-memory-mcp
#######################################
function index_project {
    local path="$1" name="${2:-}"
    local args

    args="$(jq -cn --arg p "${path}" --arg n "${name}" '{repo_path: $p, mode: "moderate"} + (if $n == "" then {} else {name: $n} end)')"
    printf '%s' "${args}" | codebase-memory-mcp cli index_repository
}

#######################################
# index_repository_root: Index the whole root, or each top-level directory when the root is too broad
#
# Globals:
#   None
#
# Arguments:
#   $1 - Repository root
#
# Outputs:
#   One line per indexed project on stdout; warnings on stderr
#
# Returns:
#   0 (best effort)
#######################################
function index_repository_root {
    local root="$1" base out dir
    local -a dirs=()

    if out="$(index_project "${root}" "" 2>&1)"; then
        echo "codebase-memory-mcp: indexed ${root}"
        return 0
    fi
    if [[ ${out} != *"too broad"* ]]; then
        echo "[warn] codebase-memory-mcp indexing failed: ${out}" >&2
        return 0
    fi

    base="$(basename "${root}")"
    while IFS= read -r dir; do
        if [[ -n ${dir} && -d ${root}/${dir} ]]; then
            dirs+=("${dir}")
        fi
    done < <(git -C "${root}" ls-files | awk -F/ 'NF > 1 {print $1}' | sort -u)

    for dir in "${dirs[@]}"; do
        if index_project "${root}/${dir}" "${base}-${dir#.}" > /dev/null 2>&1; then
            echo "codebase-memory-mcp: indexed ${root}/${dir} as ${base}-${dir#.}"
        else
            echo "[warn] codebase-memory-mcp indexing failed: ${root}/${dir}" >&2
        fi
    done
    return 0
}

#######################################
# install_apm: Run apm install --frozen when apm.yml exists
#
# Globals:
#   REPO_ROOT - Repository root holding apm.yml
#
# Arguments:
#   None
#
# Outputs:
#   Warning with lockfile recovery steps on stderr when apm install --frozen fails
#
# Returns:
#   0
#######################################
function install_apm {
    command -v apm > /dev/null 2>&1 || return 0
    # Without apm.yml apm install still works but installs no packages
    [[ -f ${REPO_ROOT}/apm.yml ]] || return 0
    (
        cd "${REPO_ROOT}" || exit
        if ! apm install --frozen; then
            echo "[warn] apm install --frozen failed: apm.lock.yaml may be out of date with apm.yml." >&2
            echo "[warn] Run 'apm install' (without --frozen) in ${REPO_ROOT} and commit apm.lock.yaml." >&2
        fi
    )
}

#######################################
# install_aqua: Run aqua lazy install and apply the aqua policy when aqua.yaml exists
#
# Globals:
#   HOME      - Home directory holding the aqua data directory
#   REPO_ROOT - Repository root holding aqua.yaml and aqua-policy.yaml
#
# Arguments:
#   None
#
# Outputs:
#   Warnings on stderr when a step fails
#
# Returns:
#   0
#######################################
function install_aqua {
    command -v aqua > /dev/null 2>&1 || return 0
    # Without aqua.yaml lazy install still works but the policy application is skipped
    [[ -f ${REPO_ROOT}/aqua.yaml ]] || return 0
    (
        cd "${REPO_ROOT}" || exit
        mkdir -p "${HOME}/.local/share/aquaproj-aqua" 2> /dev/null || true
        aqua i -l || echo "[warn] aqua lazy install failed" >&2
        aqua policy allow "${REPO_ROOT}/aqua-policy.yaml" 2> /dev/null || echo "[warn] aqua policy apply failed" >&2
    )
}

#######################################
# install_gh_extension: Install the gh-aw extension when it is missing
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Warning on stderr when the install fails
#
# Returns:
#   0
#######################################
function install_gh_extension {
    command -v gh > /dev/null 2>&1 || return 0
    if ! gh extension list 2> /dev/null | grep -q "github/gh-aw"; then
        gh extension install github/gh-aw || echo "[warn] gh extension install failed" >&2
    fi
}

#######################################
# install_mise: Trust mise.toml, install the pinned tools and expose the shims on PATH
#
# Description:
#   Writes /etc/profile.d/mise-shims.sh so login shells that do not source .bashrc (for example
#   zsh) see the shims. Cursor hooks inherit PATH from remoteEnv in devcontainer.json, not from
#   profile.d.
#
# Globals:
#   HOME      - Home directory holding the mise shims
#   REPO_ROOT - Repository root holding mise.toml
#
# Arguments:
#   None
#
# Outputs:
#   Warnings on stderr when a mise step fails
#
# Returns:
#   0
#######################################
function install_mise {
    local mise_shims="${HOME}/.local/share/mise/shims"
    command -v mise > /dev/null 2>&1 || return 0
    [[ -f ${REPO_ROOT}/mise.toml ]] || return 0
    (
        cd "${REPO_ROOT}" || exit
        mise trust --yes "${REPO_ROOT}/mise.toml" > /dev/null 2>&1 || echo "[warn] mise trust failed" >&2
        mise install || echo "[warn] mise install task failed" >&2
        mise reshim --yes || echo "[warn] mise reshim failed" >&2
        mise prune --yes || echo "[warn] mise prune failed" >&2
        if [[ -d ${mise_shims} ]]; then
            printf '%s\n' \
                '# mise shims on PATH (devcontainer; see .devcontainer/devcontainer.json remoteEnv)' \
                "export PATH=\"${mise_shims}:\$PATH\"" \
                | sudo tee /etc/profile.d/mise-shims.sh > /dev/null
            sudo chmod 644 /etc/profile.d/mise-shims.sh
        fi
    )
}

#######################################
# install_mise_global_node: Install the repository-pinned node as the mise global node
#
# Description:
#   pre-commit runs hooks with "language_version: system" (see .pre-commit-config.yaml), so a node
#   must resolve outside the repository directory too. The global version is the one mise.toml
#   pins (read with "mise current node"), never a wildcard. MISE_LOCKED=0 lets mise write the
#   global entry, which mise.lock does not cover.
#
# Globals:
#   REPO_ROOT - Repository root holding mise.toml
#
# Arguments:
#   None
#
# Outputs:
#   Warnings on stderr when a mise step fails
#
# Returns:
#   0
#######################################
function install_mise_global_node {
    local version
    command -v mise > /dev/null 2>&1 || return 0
    [[ -f ${REPO_ROOT}/mise.toml ]] || return 0
    version="$(cd "${REPO_ROOT}" && mise current node 2> /dev/null || true)"
    if [[ -z ${version} ]]; then
        echo "[warn] mise global node skipped: mise.toml pins no node" >&2
        return 0
    fi
    MISE_LOCKED=0 mise use -g "node@${version}" || echo "[warn] mise use -g node@${version} failed" >&2
}

#######################################
# install_pre_commit: Install the pre-commit and commit-msg hooks when a config exists
#
# Globals:
#   REPO_ROOT - Repository root holding .pre-commit-config.yaml
#
# Arguments:
#   None
#
# Outputs:
#   Warning on stderr when the install fails
#
# Returns:
#   0
#######################################
function install_pre_commit {
    command -v pre-commit > /dev/null 2>&1 || return 0
    [[ -f ${REPO_ROOT}/.pre-commit-config.yaml ]] || return 0
    (
        cd "${REPO_ROOT}" || exit
        pre-commit install
        pre-commit install --hook-type commit-msg
    ) || echo "[warn] pre-commit install failed" >&2
}

#######################################
# prepare_terraform: Create the Terraform plugin cache directory and initialize tflint
#
# Globals:
#   HOME      - Home directory holding the plugin cache
#   REPO_ROOT - Repository root holding .tflint.hcl
#
# Arguments:
#   None
#
# Outputs:
#   Warning on stderr when tflint init fails
#
# Returns:
#   0
#######################################
function prepare_terraform {
    mkdir -p "${HOME}/.terraform.d/plugin-cache"

    command -v tflint > /dev/null 2>&1 || return 0
    [[ -f ${REPO_ROOT}/.tflint.hcl ]] || return 0
    (
        cd "${REPO_ROOT}" || exit
        tflint --init || echo "[warn] tflint init failed" >&2
    )
}

#######################################
# resolve_repo_root: Print the repository root for the workspace
#
# Globals:
#   WORKSPACE - Workspace folder used when git cannot resolve a root
#
# Arguments:
#   None
#
# Outputs:
#   Repository root path on stdout
#
# Returns:
#   0
#######################################
function resolve_repo_root {
    local root=""

    if command -v git > /dev/null 2>&1; then
        if git -C "${WORKSPACE}" rev-parse --show-toplevel > /dev/null 2>&1; then
            root="$(git -C "${WORKSPACE}" rev-parse --show-toplevel 2> /dev/null || true)"
        else
            root="$(git rev-parse --show-toplevel 2> /dev/null || true)"
        fi
    fi
    if [[ -z ${root} ]]; then
        root="${WORKSPACE}"
    fi
    printf '%s' "${root}"
}
