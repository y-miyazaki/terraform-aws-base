#!/usr/bin/env bash
# ============================================================================
# Awesome Statusline — Cursor CLI
# ============================================================================
# Line 1: 🤖 Model | 🎨 Style | 📂 path 🌿(branch)✅
# Line 2: 🧠 Context bar % │ 🪙 Token In/Out [| 5H / 7D when rate_limits present]
# Design aligned with .claude/scripts/statusline.sh; fields omitted when absent.
# ============================================================================

set -euo pipefail

# Cursor CLI spawns statusline with a minimal PATH (no shell).
JQ="$(command -v jq 2> /dev/null || true)"
GIT="$(command -v git 2> /dev/null || true)"
[ -z "$JQ" ] && JQ=/usr/bin/jq
[ -z "$GIT" ] && GIT=/usr/local/bin/git

input=$(cat)

# Parse JSON input (StatusLinePayload — see statusline skill)
MODEL=$("$JQ" -r '.model.display_name // "Unknown"' <<< "$input")
PARAM_SUMMARY=$("$JQ" -r '.model.param_summary // empty' <<< "$input")
MAX_MODE=$("$JQ" -r '.model.max_mode // false' <<< "$input")
CURRENT_DIR=$("$JQ" -r '.workspace.current_dir // .cwd // "."' <<< "$input")
CONTEXT_SIZE=$("$JQ" -r '.context_window.context_window_size // 200000' <<< "$input")
USED_PCT_RAW=$("$JQ" -r '.context_window.used_percentage // empty' <<< "$input")
CURRENT_USAGE=$("$JQ" -r '.context_window.current_usage // null' <<< "$input")
TOTAL_INPUT_RAW=$("$JQ" -r '.context_window.total_input_tokens // empty' <<< "$input")
TOTAL_OUTPUT_RAW=$("$JQ" -r '.context_window.total_output_tokens // empty' <<< "$input")
OUTPUT_STYLE=$("$JQ" -r '.output_style.name // empty' <<< "$input")
VIM_MODE=$("$JQ" -r '.vim.mode // empty' <<< "$input")
WORKTREE=$("$JQ" -r '.worktree.name // empty' <<< "$input")

# Rate limits — Claude Code payload; shown only when present
FIVE_HOUR_PCT=$("$JQ" -r '.rate_limits.five_hour.used_percentage // empty' <<< "$input")
FIVE_HOUR_RESET=$("$JQ" -r '.rate_limits.five_hour.resets_at // empty' <<< "$input")
SEVEN_DAY_PCT=$("$JQ" -r '.rate_limits.seven_day.used_percentage // empty' <<< "$input")
SEVEN_DAY_RESET=$("$JQ" -r '.rate_limits.seven_day.resets_at // empty' <<< "$input")

# ============================================================================
# Colors
# ============================================================================
RESET="\033[0m"
BOLD="\033[1m"
CLR="\033[K"

C_TEAL="\033[38;2;148;226;213m"
C_PINK="\033[38;2;245;194;231m"
C_PEACH="\033[38;2;250;179;135m"
C_GREEN="\033[38;2;166;227;161m"
C_SUBTEXT="\033[38;2;166;173;200m"
C_LAVENDER="\033[38;2;180;190;254m"
C_YELLOW="\033[38;2;249;226;175m"
C_LATTE_GREEN="\033[38;2;64;160;43m"
C_LATTE_YELLOW="\033[38;2;223;142;29m"
C_TOKEN_IN="\033[38;2;137;180;250m"
C_TOKEN_OUT="\033[38;2;250;179;135m"

# ============================================================================
# Helpers
# ============================================================================
format_compact_tokens() {
    local n="${1:-}"
    if [[ -z $n || $n == "null" ]]; then
        printf '—'
        return 0
    fi
    if ((n >= 1000000)); then
        printf '%d.%dM' $((n / 1000000)) $(((n % 1000000) / 100000))
    elif ((n >= 1000)); then
        printf '%dK' $(((n + 500) / 1000))
    else
        printf '%d' "$n"
    fi
}

# ============================================================================
# Gradient helpers
# ============================================================================
get_context_gradient_color() {
    local pct=$1
    local r g b t
    if [[ $pct -lt 30 ]]; then
        t=$((pct * 100 / 30))
        r=$((245 + (230 - 245) * t / 100))
        g=$((194 + (69 - 194) * t / 100))
        b=$((231 + (83 - 231) * t / 100))
    elif [[ $pct -lt 70 ]]; then
        t=$(((pct - 30) * 100 / 40))
        r=$((230 + (210 - 230) * t / 100))
        g=$((69 + (15 - 69) * t / 100))
        b=$((83 + (57 - 83) * t / 100))
    else
        r=210
        g=15
        b=57
    fi
    echo "$r;$g;$b"
}

get_usage_gradient_color() {
    local pct=$1
    local r g b t
    if [[ $pct -lt 50 ]]; then
        t=$((pct * 2))
        r=$((180 + (30 - 180) * t / 100))
        g=$((190 + (102 - 190) * t / 100))
        b=$((254 + (245 - 254) * t / 100))
    else
        t=$(((pct - 50) * 2))
        r=$((30 + (210 - 30) * t / 100))
        g=$((102 + (15 - 102) * t / 100))
        b=$((245 + (57 - 245) * t / 100))
    fi
    echo "$r;$g;$b"
}

get_usage_7d_gradient_color() {
    local pct=$1
    local r g b t
    if [[ $pct -lt 50 ]]; then
        t=$((pct * 2))
        r=$((249 + (254 - 249) * t / 100))
        g=$((226 + (100 - 226) * t / 100))
        b=$((175 + (11 - 175) * t / 100))
    else
        t=$(((pct - 50) * 2))
        r=$((254 + (210 - 254) * t / 100))
        g=$((100 + (15 - 100) * t / 100))
        b=$((11 + (57 - 11) * t / 100))
    fi
    echo "$r;$g;$b"
}

generate_bar() {
    local pct=$1
    local width=$2
    local type=$3
    local bar=""
    local filled=$(((pct * width + 50) / 100))
    [[ $filled -gt $width ]] && filled=$width

    local end_color i block_pct color
    case "$type" in
        context) end_color=$(get_context_gradient_color "$pct") ;;
        7d) end_color=$(get_usage_7d_gradient_color "$pct") ;;
        *) end_color=$(get_usage_gradient_color "$pct") ;;
    esac

    for ((i = 0; i < filled; i++)); do
        block_pct=$((i * 100 / width))
        case "$type" in
            context) color=$(get_context_gradient_color "$block_pct") ;;
            7d) color=$(get_usage_7d_gradient_color "$block_pct") ;;
            *) color=$(get_usage_gradient_color "$block_pct") ;;
        esac
        bar+="\033[38;2;${color}m█"
    done

    for ((i = filled; i < width; i++)); do
        bar+="\033[38;2;${end_color}m░"
    done

    printf '%b%b' "$bar" "$RESET"
}

format_time_remaining() {
    local reset_epoch="$1"
    [[ -z $reset_epoch || $reset_epoch == "null" ]] && return 0
    local now_epoch remaining hours minutes
    now_epoch=$(date +%s)
    remaining=$((reset_epoch - now_epoch))
    [[ $remaining -lt 0 ]] && remaining=0
    hours=$((remaining / 3600))
    minutes=$(((remaining % 3600) / 60))
    printf '%sh%sm' "$hours" "$minutes"
}

_date_fmt() {
    local epoch="$1" fmt="$2" out=""
    out=$(date -j -f "%s" "$epoch" "+$fmt" 2> /dev/null) && [[ -n $out ]] && {
        printf '%s' "$out"
        return 0
    }
    out=$(date -r "$epoch" "+$fmt" 2> /dev/null) && [[ -n $out ]] && {
        printf '%s' "$out"
        return 0
    }
    date -d "@$epoch" "+$fmt" 2> /dev/null || true
}

format_reset_day() {
    local reset_epoch="$1"
    [[ -z $reset_epoch || $reset_epoch == "null" ]] && return 0
    _date_fmt "$reset_epoch" "%a"
}

# ============================================================================
# Line 1: Model | Style | Directory + Git
# ============================================================================
MODEL_DISPLAY="🤖 ${BOLD}${C_TEAL}${MODEL}${RESET}"
# Skip param_summary when already embedded in display_name (e.g. "… High Fast" + "High Fast")
if [[ -n $PARAM_SUMMARY ]]; then
    case "$MODEL" in
        *"$PARAM_SUMMARY"*) ;;
        *) MODEL_DISPLAY="${MODEL_DISPLAY} ${C_PEACH}${PARAM_SUMMARY}${RESET}" ;;
    esac
fi
[[ $MAX_MODE == "true" ]] && MODEL_DISPLAY="${MODEL_DISPLAY} ${C_YELLOW}MAX${RESET}"
[[ -n $VIM_MODE ]] && MODEL_DISPLAY="${MODEL_DISPLAY} ${C_LAVENDER}[${VIM_MODE}]${RESET}"

STYLE_DISPLAY=""
[[ -n $OUTPUT_STYLE ]] && STYLE_DISPLAY=" │ 🎨 ${C_PEACH}${OUTPUT_STYLE}${RESET}"

case "$CURRENT_DIR" in
    "$HOME") DIR_PATH="~" ;;
    "$HOME"/*) DIR_PATH="~${CURRENT_DIR#"$HOME"}" ;;
    *) DIR_PATH="$CURRENT_DIR" ;;
esac
DIR_DISPLAY="📂 ${C_SUBTEXT}${DIR_PATH}${RESET}"

WORKTREE_DISPLAY=""
[[ -n $WORKTREE ]] && WORKTREE_DISPLAY=" ${C_LAVENDER}🌳(${WORKTREE})${RESET}"

GIT_DISPLAY=""
if [ -x "$GIT" ] && "$GIT" -C "$CURRENT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$("$GIT" -C "$CURRENT_DIR" branch --show-current 2> /dev/null || true)
    [[ -n $BRANCH ]] && GIT_DISPLAY="${C_LATTE_GREEN}🌿(${BRANCH})${RESET}"

    STAGED=$("$GIT" -C "$CURRENT_DIR" diff --cached --name-only 2> /dev/null | wc -l | tr -d ' ')
    UNSTAGED=$("$GIT" -C "$CURRENT_DIR" diff --name-only 2> /dev/null | wc -l | tr -d ' ')
    UNTRACKED=$("$GIT" -C "$CURRENT_DIR" ls-files --others --exclude-standard 2> /dev/null | wc -l | tr -d ' ')

    if [[ $STAGED -eq 0 && $UNSTAGED -eq 0 && $UNTRACKED -eq 0 ]]; then
        GIT_DISPLAY="${GIT_DISPLAY}${C_GREEN}✅${RESET}"
    else
        STATUS=""
        [[ $STAGED -gt 0 ]] && STATUS="${STATUS}+"
        [[ $UNSTAGED -gt 0 ]] && STATUS="${STATUS}!"
        [[ $UNTRACKED -gt 0 ]] && STATUS="${STATUS}?"
        GIT_DISPLAY="${GIT_DISPLAY}${C_LATTE_YELLOW}📝${STATUS}${RESET}"
    fi
fi

LINE1="${MODEL_DISPLAY}${STYLE_DISPLAY} │ ${DIR_DISPLAY}${WORKTREE_DISPLAY} ${GIT_DISPLAY}"

# ============================================================================
# Line 2: Context [+ rate limits when available]
# ============================================================================
CONTEXT_PERCENT=0
if [[ -n $USED_PCT_RAW && $USED_PCT_RAW != "null" ]]; then
    CONTEXT_PERCENT=$(printf '%.0f' "$USED_PCT_RAW")
elif [[ $CURRENT_USAGE != "null" && -n $CURRENT_USAGE ]]; then
    INPUT_TOKENS=$("$JQ" -r '.input_tokens // 0' <<< "$CURRENT_USAGE")
    CACHE_CREATE=$("$JQ" -r '.cache_creation_input_tokens // 0' <<< "$CURRENT_USAGE")
    CACHE_READ=$("$JQ" -r '.cache_read_input_tokens // 0' <<< "$CURRENT_USAGE")
    CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))
    [[ $CONTEXT_SIZE -gt 0 ]] && CONTEXT_PERCENT=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
fi

CTX_BAR=$(generate_bar "$CONTEXT_PERCENT" 10 "context")
CTX_END_COLOR=$(get_context_gradient_color "$CONTEXT_PERCENT")
CTX_SIZE_LABEL=$(format_compact_tokens "$CONTEXT_SIZE")
CTX_DISPLAY="🧠 ${C_PINK}Context${RESET} ${CTX_BAR} ${BOLD}\033[38;2;${CTX_END_COLOR}m${CONTEXT_PERCENT}%${RESET} ${C_SUBTEXT}(${CTX_SIZE_LABEL})${RESET}"

TOKEN_IN=$(format_compact_tokens "$TOTAL_INPUT_RAW")
TOKEN_OUT=$(format_compact_tokens "$TOTAL_OUTPUT_RAW")
TOKEN_DISPLAY="🪙 ${C_SUBTEXT}Token${RESET} ${C_TOKEN_IN}In ${BOLD}${TOKEN_IN}${RESET} ${C_TOKEN_OUT}Out ${BOLD}${TOKEN_OUT}${RESET}"

if [[ -n $FIVE_HOUR_PCT ]]; then
    FIVE_HOUR=$(printf '%.0f' "$FIVE_HOUR_PCT")
    SEVEN_DAY=$(printf '%.0f' "${SEVEN_DAY_PCT:-0}")

    FIVE_RESET_FMT=$(format_time_remaining "$FIVE_HOUR_RESET")
    SEVEN_RESET_FMT=$(format_reset_day "$SEVEN_DAY_RESET")

    FIVE_BAR=$(generate_bar "$FIVE_HOUR" 10 "5h")
    SEVEN_BAR=$(generate_bar "$SEVEN_DAY" 10 "7d")

    FIVE_END_COLOR=$(get_usage_gradient_color "$FIVE_HOUR")
    SEVEN_END_COLOR=$(get_usage_7d_gradient_color "$SEVEN_DAY")

    FIVE_DISPLAY="${C_LAVENDER}5H${RESET} ${FIVE_BAR} ${BOLD}\033[38;2;${FIVE_END_COLOR}m${FIVE_HOUR}%${RESET} (${FIVE_RESET_FMT})"
    SEVEN_DISPLAY="${C_YELLOW}7D${RESET} ${SEVEN_BAR} ${BOLD}\033[38;2;${SEVEN_END_COLOR}m${SEVEN_DAY}%${RESET} (${SEVEN_RESET_FMT})"

    LINE2="${CTX_DISPLAY} │ ${TOKEN_DISPLAY} │ ${FIVE_DISPLAY} │ ${SEVEN_DISPLAY}"
else
    LINE2="${CTX_DISPLAY} │ ${TOKEN_DISPLAY}"
fi

# ============================================================================
# Output
# ============================================================================
printf '%b%b\n' "$LINE1" "$CLR"
printf '%b%b\n' "$LINE2" "$CLR"
