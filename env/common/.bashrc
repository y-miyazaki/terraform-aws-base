# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "$(dircolors)"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'

# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

#######################################
# Codespaces bash prompt theme
#######################################
__bash_prompt() {
    local userpart='`export XIT=$? \
        && [ ! -z "${GITHUB_USER}" ] && echo -n "\[\033[0;32m\]@${GITHUB_USER} " || echo -n "\[\033[0;32m\]\u " \
        && [ "$XIT" -ne "0" ] && echo -n "\[\033[1;31m\]➜" || echo -n "\[\033[0m\]➜"`'
    local aws_profile=$([ ! -z "${AWS_PROFILE}" ] && echo -n "\[\033[0;31m\]${AWS_PROFILE} \[\033[0m\]➜" || echo -n "\[\033[0;31m\](no) \[\033[0m\]➜")
    # local envpart=`[ ! -z "${ENV}" ] && echo -n "\[\033[0;31m\]${ENV} \[\033[0m\]➜" || echo -n "\[\033[0;31m\](no) \[\033[0m\]➜"`
    local gitbranch='`\
        if [ "$(git config --get codespaces-theme.hide-status 2>/dev/null)" != 1 ]; then \
            export BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null); \
            if [ "${BRANCH}" != "" ]; then \
                echo -n "\[\033[0;36m\](\[\033[1;31m\]${BRANCH}" \
                && if git ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" > /dev/null 2>&1; then \
                        echo -n " \[\033[1;33m\]✗"; \
                fi \
                && echo -n "\[\033[0;36m\]) "; \
            fi; \
        fi`'
    local lightblue='\[\033[1;34m\]'
    local removecolor='\[\033[0m\]'
    PS1="${userpart} ${aws_profile} ${lightblue}\w ${gitbranch}${removecolor}\$ "
    unset -f __bash_prompt
}
__bash_prompt
export PROMPT_DIRTRIM=4

#######################################
# for terraform
#######################################
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
alias tinit='terraform init -reconfigure -backend-config="terraform.${ENV}.tfbackend"'
alias tinitupgrade='terraform init -upgrade -reconfigure -backend-config="terraform.${ENV}.tfbackend"'
alias tplan='terraform plan -lock=false -var-file="terraform.${ENV}.tfvars"'
alias tapply='terraform apply -auto-approve -var-file="terraform.${ENV}.tfvars"'

#######################################
# for aqua
#######################################
export PATH="$(aqua root-dir)/bin:$PATH"

# export PYENV_ROOT="/home/${USER}/.pyenv"
# export PATH="$PYENV_ROOT/bin/:$PATH"
# eval "$(pyenv init -)"
#######################################
# for aws
#######################################
alias awsp="source _awsp; source ~/.bashrc"
alias awsc='eval $(aws configure export-credentials --format env)'

#######################################
# for enable auto-completion
#######################################
complete -C 'aws_completer' aws
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

#######################################
# for GitHub Copilot CLI
#######################################
# Copilot / VSCode environment defaults (do not place secrets directly in this file)
export COPILOT_BASE="/workspace/.copilot"
# Allow Copilot to use all permissions (tools/paths/urls)
export COPILOT_ALLOW_ALL="1"
# Default model (can be overridden by --model flag or /model command)
export COPILOT_MODEL="gpt-5-mini"
# Additional directories to search for custom instructions files (comma-separated)
export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="/workspace/.github/instructions"
# Use bundled ripgrep (set to "false" to use ripgrep from PATH instead)
export USE_BUILTIN_RIPGREP="true"

# Token resolution:
#   copilot CLI: COPILOT_GITHUB_TOKEN > GH_TOKEN > GITHUB_TOKEN > stored credentials
#   gh CLI:      GH_TOKEN > stored credentials (managed by gh auth login)
# Using COPILOT_GITHUB_TOKEN for copilot-only token, GH_TOKEN for gh CLI,
# keeping them separate so each tool can use a different token if needed.

# Copilot-specific token (file takes precedence; gives copilot CLI its own identity)
if [ -f "${COPILOT_BASE}/copilot_github_token" ]; then
    export COPILOT_GITHUB_TOKEN="$(cat "${COPILOT_BASE}/copilot_github_token")"
fi

# GH_TOKEN: prefer gh credential store; fall back to file for headless/CI environments
if command -v gh > /dev/null 2>&1 && gh auth status > /dev/null 2>&1; then
    export GH_TOKEN="$(gh auth token 2> /dev/null)"
elif [ -f "${COPILOT_BASE}/gh_token" ]; then
    export GH_TOKEN="$(cat "${COPILOT_BASE}/gh_token")"
fi

# GITHUB_TOKEN: same strategy — prefer gh, fall back to file only if not already set
if [ -z "${GITHUB_TOKEN-}" ]; then
    if command -v gh > /dev/null 2>&1 && gh auth status > /dev/null 2>&1; then
        export GITHUB_TOKEN="$(gh auth token 2> /dev/null)"
    elif [ -f "${COPILOT_BASE}/github_token" ]; then
        export GITHUB_TOKEN="$(cat "${COPILOT_BASE}/github_token")"
    fi
fi

# XDG dirs
export XDG_CONFIG_HOME="/home/${USER}/.config"
