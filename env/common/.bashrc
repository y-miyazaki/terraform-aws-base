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

# Codespaces bash prompt theme
__bash_prompt() {
    local userpart='`export XIT=$? \
        && [ ! -z "${GITHUB_USER}" ] && echo -n "\[\033[0;32m\]@${GITHUB_USER} " || echo -n "\[\033[0;32m\]\u " \
        && [ "$XIT" -ne "0" ] && echo -n "\[\033[1;31m\]➜" || echo -n "\[\033[0m\]➜"`'
    local aws_profile=`[ ! -z "${AWS_PROFILE}" ] && echo -n "\[\033[0;31m\]${AWS_PROFILE} \[\033[0m\]➜" || echo -n "\[\033[0;31m\](no) \[\033[0m\]➜"`
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
# export PYENV_ROOT="/home/${USER}/.pyenv"
# export PATH="$PYENV_ROOT/bin/:$PATH"
# eval "$(pyenv init -)"
export PATH="/usr/local/bin/gh_2.21.1_linux_amd64/bin:$PATH"
alias awsp="source _awsp; source ~/.bashrc"
alias awsc="eval $(aws configure export-credentials --format env)"
