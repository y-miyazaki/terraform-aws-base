#!/bin/bash
#######################################
# Description: Validate a github-pr-review report and render it as a COMMENT review file
#
# Usage: ./render_review.sh
#   Runs as the loop finalize_script in finalize (after the checker verdict); the platform
#   delivers the rendered file as one COMMENT PR review.
#
# Output:
# - Writes ${LOOP_MESSAGE_DIR}/review.json = {"body", "commit_id", "comments", "fallback_body"}
#   (reviews API shape without event); log lines and ::warning:: annotations on stdout
#
# Design Rules:
# - Render only; never posts (no gh api POST) and never reads LOOP_META_BLOCK (the platform
#   adds Meta and footer when it delivers)
# - Act only when VERDICT is APPROVE; any other verdict writes nothing
# - Fail closed: unset LOOP_MESSAGE_DIR, unparseable TARGET_JSON or report, or unavailable trusted
#   SHAs write nothing, warn, and exit 0
# - Report base_sha/head_sha are never trusted: the PR's SHAs come from gh pr view and are used
#   for evidence checks, all links, and commit_id. A report head_sha that is missing or differs
#   from the PR head fails closed (the PR moved); a base_sha mismatch is only warned about
# - rule / criteria findings are kept only when evidence.quote is an exact substring
#   (no normalization) of evidence.path as committed at the trusted base SHA (git cat-file,
#   not the working tree); other invalid findings are dropped
# - in_diff findings whose lines are not in the PR diff move to the review body
# - At most MAX_FINDINGS findings are rendered (most severe kept); the omitted count is in the body
# - Paths in link labels are escaped when they contain backticks, brackets, or backslashes
# - fallback_body is always written: the same review with every finding in the body, for the
#   platform's one retry without inline comments when GitHub rejects them (HTTP 422)
# - The body starts with the github-pr-review marker; review.json has no event key (the
#   platform always posts COMMENT)
# - Unexpected errors emit ::warning:: and exit 0 so finalize does not fail
#   (main runs in a set -e subshell; the entry guard always exits 0)
# - Render fixed English headings and labels from the template defs in REVIEW_JQ_LIB
#   (mirrors assets/review-body-template.md and assets/inline-comment-template.md)
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/apm/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - jq, awk
# - git (base commit blobs; report fetch when REPORT_FILE is unset); cwd is the repository
# - gh (read only: gh pr view when PR_BASE_SHA/PR_HEAD_SHA are unset; gh pr diff when PR_DIFF_FILE is unset)
#
# Environment:
#   VERDICT               Checker verdict; only APPROVE renders
#   EXECUTE_BRANCH        Work branch holding the report file
#   TARGET_JSON           Loop target JSON; PR number from .entity.handoff_key // .key (entity:pr:<n>)
#   GITHUB_REPOSITORY     owner/repo
#   GH_TOKEN / GITHUB_TOKEN Token for gh read calls
#   LOOP_MESSAGE_DIR      Directory that receives review.json (required)
#   REPORT_FILE           Report path to read instead of git fetch + git show (test seam)
#   PR_DIFF_FILE          Unified diff to read instead of gh pr diff (test seam)
#   PR_BASE_SHA / PR_HEAD_SHA Trusted PR SHAs instead of gh pr view (test seam; both required)
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=./lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

readonly REVIEW_MARKER='<!-- github-pr-review:v1 -->'
# Most findings one review renders; the rest are omitted (most severe kept) and counted in the body
readonly MAX_FINDINGS=20

# jq defs shared by the renderers. review_body_template and inline_comment_template (with
# finding_item / evidence_line) hold every fixed English string of the rendered review; keep them
# in sync with the skill's assets/review-body-template.md and assets/inline-comment-template.md.
# shellcheck disable=SC2016 # jq program: $vars are jq bindings, not shell expansions
readonly REVIEW_JQ_LIB='
def enc_path: split("/") | map(@uri) | join("/");
def indent($n): gsub("\n"; "\n" + (" " * $n));
def line_anchor: if .start_line then "L\(.start_line)-L\(.line)" else "L\(.line)" end;
def md_label:
  if test("[`\\[\\]\\\\]") then gsub("(?<c>[`\\[\\]\\\\])"; "\\\(.c)") else "`" + . + "`" end;
def verbatim_quote($n):
  if contains("\n") then "\n" + (" " * $n) + ("````text\n" + . + "\n````" | indent($n))
  else " \"\(.)\"" end;
def evidence_line($repo; $base; $n):
  if .evidence.kind == "bug" then
    if ((.evidence.quote // "") | type) == "string" and ((.evidence.quote // "") | length) > 0
    then "- Evidence: \(.evidence.quote | indent($n))" else empty end
  else
    (if (.evidence_anchor // "") != "" then "#\(.evidence_anchor)" else "" end) as $a
    | "- Evidence: [\("\(.evidence.path)\($a)" | md_label)](https://github.com/\($repo)/blob/\($base)/\(.evidence.path | enc_path)\($a)) —\(.evidence.quote | verbatim_quote($n))"
  end;
def location_url($repo; $base; $head):
  (if (.location.side // "RIGHT") == "LEFT" then $base else $head end) as $sha
  | "https://github.com/\($repo)/blob/\($sha)/\(.location.path | enc_path)#\(.location | line_anchor)";
def inline_comment_template($repo; $base):
  "**#\(.number) [\(.severity)]** \(.title)\n\n"
  + ([evidence_line($repo; $base; 2), "- Impact: \(.impact | indent(2))"] | join("\n"))
  + "\n\nTo request a fix, reply to this comment with `@loop`.\n";
def finding_item($repo; $base; $head; $pr):
  if .inline then
    "\(.number). **[\(.severity)]** \(.title | indent(3)) — inline: [\("\(.location.path)#\(.location | line_anchor)" | md_label)](https://github.com/\($repo)/pull/\($pr)/files)"
  else
    ["\(.number). **[\(.severity)]** \(.title | indent(3))",
     (evidence_line($repo; $base; 5) | "   " + .),
     "   - Location: \(location_url($repo; $base; $head))",
     "   - Impact: \(.impact | indent(5))"] | join("\n")
  end;
def premise_text:
  if type == "string" and length > 0 then .
  elif type == "array" and length > 0 then map(tostring) | join(", ")
  else "none" end;
def review_body_template($repo; $marker):
  . as $r
  | ($r.findings // []) as $f
  | [$marker,
     "",
     "## Code review",
     "",
     "Findings: \($f | length) (Critical: \([$f[] | select(.severity == "Critical")] | length) / Warning: \([$f[] | select(.severity == "Warning")] | length) / Suggestion: \([$f[] | select(.severity == "Suggestion")] | length))",
     (if ($r.dropped // 0) > 0 then "", "Dropped: \($r.dropped) (evidence could not be verified)" else empty end),
     (if ($r.omitted // 0) > 0 then "", "Omitted: \($r.omitted) (over the limit of \($r.finding_limit) findings)" else empty end),
     "",
     ($r.summary // ""),
     "",
     "### Premises checked",
     "",
     "- PR body: \($r.premises.pr_body | premise_text)",
     "- Linked Issue / spec: \($r.premises.linked | premise_text)",
     (if ($f | length) > 0 then
        "", "### Findings", "",
        ($f[] | finding_item($repo; $r.base_sha; $r.head_sha; $r.pr_number))
      else empty end)]
  | join("\n") + "\n";
'

#######################################
# annotate_report: Drop invalid findings, cap the rest, number them, and decide inline placement
#
# Globals:
#   REVIEW_BASE_SHA
#   PR_DIFF_FILE
#   MAX_FINDINGS
#
# Arguments:
#   $1 - Report JSON (envelope validated; SHAs replaced with trusted values)
#
# Outputs:
#   Report JSON with findings[] kept (number, inline, evidence_anchor), dropped count,
#   omitted count (over MAX_FINDINGS), and finding_limit
#
# Returns:
#   0
#
# Usage:
#   annotated="$(annotate_report "${report}")"
#
#######################################
function annotate_report {
    local report="$1"
    local finding kind anchor inline path line side start
    local -a kept=()
    local total

    total="$(jq -r '.findings | length' <<< "${report}")"
    while IFS= read -r finding; do
        [[ -n ${finding} ]] || continue
        if ! validate_finding "${finding}"; then
            continue
        fi
        kind="$(jq -r '.evidence.kind' <<< "${finding}")"
        anchor=""
        if [[ ${kind} != "bug" ]]; then
            anchor="$(evidence_anchor "${finding}")"
        fi
        inline=false
        if [[ "$(jq -r '.location.in_diff == true' <<< "${finding}")" == "true" ]]; then
            path="$(jq -r '.location.path' <<< "${finding}")"
            line="$(jq -r '.location.line' <<< "${finding}")"
            side="$(jq -r '.location.side // "RIGHT"' <<< "${finding}")"
            start="$(jq -r '.location.start_line // ""' <<< "${finding}")"
            if diff_contains_line "${path}" "${line}" "${side}" "${start}"; then
                inline=true
            fi
        fi
        kept+=("$(jq -c --argjson i "${inline}" --arg a "${anchor}" \
            '.inline = $i | .evidence_anchor = $a | .location.side = (.location.side // "RIGHT")' \
            <<< "${finding}")")
    done < <(jq -c '.findings[]' <<< "${report}")

    # Keep at most MAX_FINDINGS valid findings: the most severe win (report order breaks ties),
    # then report order is restored and the survivors are numbered 1..n.
    {
        printf '%s\n' "${report}"
        if [[ ${#kept[@]} -gt 0 ]]; then
            printf '%s\n' "${kept[@]}"
        fi
    } | jq -sc --argjson total "${total}" --argjson max "${MAX_FINDINGS}" '
        def rank: {"Critical": 0, "Warning": 1, "Suggestion": 2}[.severity];
        .[0] as $r | .[1:] as $v
        | [$v | to_entries | sort_by((.value | rank), .key) | .[:$max] | sort_by(.key)
           | to_entries[] | .value.value + {number: (.key + 1)}] as $f
        | $r | .findings = $f
        | .dropped = ($total - ($v | length))
        | .omitted = (($v | length) - ($f | length))
        | .finding_limit = $max'
}

#######################################
# base_evidence_blob: Print evidence.path content as committed at the trusted base SHA
#
# Globals:
#   REVIEW_BASE_SHA - Trusted PR base commit (from resolve_trusted_shas)
#
# Arguments:
#   $1 - Evidence path (relative to the repository root)
#
# Outputs:
#   Exact blob bytes to stdout (no textconv, no working-tree content)
#
# Returns:
#   0 when the path is a regular file (mode 100644/100755) at the base commit, 1 otherwise
#
# Usage:
#   base_evidence_blob "AGENTS.md" | jq -Rs ...
#
#######################################
function base_evidence_blob {
    local rel="$1"
    local sha="${REVIEW_BASE_SHA:-}"
    local entry mode type name

    safe_relative_path "${rel}" || return 1
    [[ ${sha} =~ ^[0-9a-f]{40}$ ]] || return 1
    # -z prints the name unquoted (non-ASCII paths would otherwise be C-quoted and never match);
    # NUL becomes newline, and safe_relative_path already rejected names containing one.
    entry="$(GIT_LITERAL_PATHSPECS=1 git ls-tree -z --full-tree "${sha}" -- "${rel}" 2> /dev/null | tr '\0' '\n')" || return 1
    [[ -n ${entry} && ${entry} != *$'\n'* ]] || return 1
    name="${entry#*$'\t'}"
    read -r mode type _ <<< "${entry%%$'\t'*}"
    [[ ${name} == "${rel}" && ${type} == "blob" ]] || return 1
    [[ ${mode} == "100644" || ${mode} == "100755" ]] || return 1
    git cat-file blob "${sha}:${rel}" 2> /dev/null
}

#######################################
# build_review_json: Build review.json (reviews API shape without event, plus fallback_body)
#
# Globals:
#   GITHUB_REPOSITORY
#   REVIEW_JQ_LIB
#   REVIEW_MARKER
#
# Arguments:
#   $1 - Annotated report JSON
#
# Outputs:
#   {"body", "commit_id", "comments", "fallback_body"} JSON to stdout; fallback_body is the
#   body rendered with every finding moved out of inline comments
#
# Returns:
#   0 on success
#
# Usage:
#   build_review_json "${annotated}" > "${LOOP_MESSAGE_DIR}/review.json"
#
#######################################
function build_review_json {
    jq -c --arg repo "${GITHUB_REPOSITORY}" --arg marker "${REVIEW_MARKER}" "${REVIEW_JQ_LIB}"'
        . as $r
        | {
            body: review_body_template($repo; $marker),
            comments: [
                $r.findings[] | select(.inline)
                | {body: inline_comment_template($repo; $r.base_sha), line: .location.line,
                   path: .location.path, side: .location.side}
                  + (if .location.start_line then
                       {start_line: .location.start_line, start_side: .location.side} else {} end)
            ],
            commit_id: $r.head_sha,
            fallback_body: ($r | .findings |= map(.inline = false) | review_body_template($repo; $marker))
        }' <<< "$1"
}

#######################################
# diff_contains_line: Return whether a line is inside a hunk of the PR diff
#
# Globals:
#   PR_DIFF_FILE
#
# Arguments:
#   $1 - File path (new path; old path for deleted files)
#   $2 - Line number
#   $3 - Side (RIGHT = new file, LEFT = old file)
#   $4 - Optional start line (must be in the same hunk)
#
# Outputs:
#   None
#
# Returns:
#   0 when the line (and start line) is in one hunk, 1 otherwise
#
# Usage:
#   diff_contains_line a.sh 42 RIGHT 40
#
#######################################
function diff_contains_line {
    local diff_file="${PR_DIFF_FILE:-}"

    [[ -n ${diff_file} && -r ${diff_file} ]] || return 1
    [[ $2 =~ ^[1-9][0-9]*$ ]] || return 1
    [[ -z ${4:-} || ${4} =~ ^[1-9][0-9]*$ ]] || return 1

    DIFF_PATH="$1" DIFF_LINE="$2" DIFF_SIDE="$3" DIFF_START="${4:-}" awk '
        function strip_path(p) {
            sub(/\t.*$/, "", p)
            if (p ~ /^[ab]\//) {
                p = substr(p, 3)
            }
            return p
        }
        BEGIN {
            target = ENVIRON["DIFF_PATH"]
            line = ENVIRON["DIFF_LINE"] + 0
            side = ENVIRON["DIFF_SIDE"]
            start = (ENVIRON["DIFF_START"] == "") ? line : ENVIRON["DIFF_START"] + 0
            old_rem = 0
            new_rem = 0
            found = 0
        }
        {
            if (old_rem > 0 || new_rem > 0) {
                c = substr($0, 1, 1)
                if (c == " ") { old_rem--; new_rem-- }
                else if (c == "-") { old_rem-- }
                else if (c == "+") { new_rem-- }
                next
            }
            if ($0 ~ /^diff --git /) { old_path = ""; new_path = ""; next }
            if ($0 ~ /^--- /) { old_path = strip_path(substr($0, 5)); next }
            if ($0 ~ /^\+\+\+ /) { new_path = strip_path(substr($0, 5)); next }
            if ($0 ~ /^@@ -[0-9]+(,[0-9]+)? \+[0-9]+(,[0-9]+)? @@/) {
                split(substr($2, 2), o, ",")
                split(substr($3, 2), n, ",")
                o_start = o[1] + 0; o_len = (2 in o) ? o[2] + 0 : 1
                n_start = n[1] + 0; n_len = (2 in n) ? n[2] + 0 : 1
                old_rem = o_len
                new_rem = n_len
                matches = (new_path != "/dev/null" && new_path == target) || (new_path == "/dev/null" && old_path == target)
                if (!matches) { next }
                if (side == "LEFT") { lo = o_start; hi = o_start + o_len - 1 }
                else { lo = n_start; hi = n_start + n_len - 1 }
                if (line >= lo && line <= hi && start >= lo && start <= hi) { found = 1 }
            }
        }
        END { exit(found ? 0 : 1) }
    ' "${diff_file}"
}

#######################################
# evidence_anchor: Print the base line anchor (L<s> or L<s>-L<e>) of a verified quote
#
# Globals:
#   REVIEW_BASE_SHA
#
# Arguments:
#   $1 - Finding JSON (rule or criteria, already validated)
#
# Outputs:
#   Anchor without the leading # to stdout (empty when unavailable)
#
# Returns:
#   0
#
# Usage:
#   anchor="$(evidence_anchor "${finding}")"
#
#######################################
function evidence_anchor {
    local finding="$1"
    local path

    path="$(jq -r '.evidence.path // ""' <<< "${finding}")" || return 0
    base_evidence_blob "${path}" | jq -Rrs --argjson f "${finding}" '
        . as $content
        | $f.evidence.quote as $q
        | ($q | match("^\n*").length) as $lead
        | (($content | split($q)[0] | split("\n") | length) + $lead) as $start
        | ([($q | gsub("^\n+|\n+$"; "") | split("\n") | length), 1] | max) as $count
        | ($start + $count - 1) as $end
        | if $end > $start then "L\($start)-L\($end)" else "L\($start)" end
    ' 2> /dev/null || true
}

#######################################
# read_report: Print the report JSON (REPORT_FILE or the work branch)
#
# Globals:
#   REPORT_FILE
#   EXECUTE_BRANCH
#
# Arguments:
#   $1 - Report path in the repository (.loop-review/pr-<n>.json)
#
# Outputs:
#   Report content to stdout
#
# Returns:
#   0 on success, 1 when the report cannot be read
#
# Usage:
#   report="$(read_report ".loop-review/pr-7.json")"
#
#######################################
function read_report {
    local report_path="$1"
    local branch="${EXECUTE_BRANCH:-}"

    if [[ -n ${REPORT_FILE:-} ]]; then
        [[ -f ${REPORT_FILE} ]] || return 1
        cat "${REPORT_FILE}"
        return 0
    fi

    if [[ ! ${branch} =~ ^[A-Za-z0-9/_.-]+$ || ${branch} == *..* ]]; then
        return 1
    fi
    git fetch --no-tags --quiet origin "+refs/heads/${branch}:refs/remotes/origin/${branch}" > /dev/null 2>&1 || return 1
    git show "origin/${branch}:${report_path}" 2> /dev/null
}

#######################################
# render_inline_comment: Render one inline comment body from an annotated finding
#
# Globals:
#   GITHUB_REPOSITORY
#   REVIEW_BASE_SHA (default for $2)
#   REVIEW_JQ_LIB
#
# Arguments:
#   $1 - Annotated finding JSON (number, severity, title, evidence, impact)
#   $2 - Optional base SHA for evidence links
#
# Outputs:
#   Markdown comment to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   render_inline_comment "${finding}" "${base_sha}"
#
#######################################
function render_inline_comment {
    jq -r --arg repo "${GITHUB_REPOSITORY}" --arg base "${2:-${REVIEW_BASE_SHA:-}}" \
        "${REVIEW_JQ_LIB} inline_comment_template(\$repo; \$base)" <<< "$1"
}

#######################################
# render_review_body: Render the review body from an annotated report
#
# Globals:
#   GITHUB_REPOSITORY
#   REVIEW_JQ_LIB
#   REVIEW_MARKER
#
# Arguments:
#   $1 - Annotated report JSON (see annotate_report)
#
# Outputs:
#   Markdown body to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   render_review_body "${annotated}"
#
#######################################
function render_review_body {
    jq -r --arg repo "${GITHUB_REPOSITORY}" --arg marker "${REVIEW_MARKER}" \
        "${REVIEW_JQ_LIB} review_body_template(\$repo; \$marker)" <<< "$1"
}

#######################################
# resolve_pr_number: Extract the PR number from TARGET_JSON
#
# Globals:
#   None
#
# Arguments:
#   $1 - TARGET_JSON
#
# Outputs:
#   PR number to stdout
#
# Returns:
#   0 on success, 1 when the handoff key is missing or not entity:pr:<n>
#
# Usage:
#   pr_number="$(resolve_pr_number "${TARGET_JSON}")"
#
#######################################
function resolve_pr_number {
    local key

    key="$(jq -r '(.entity.handoff_key // .key // "") | tostring' <<< "$1" 2> /dev/null)" || return 1
    if [[ ! ${key} =~ ^entity:pr:([1-9][0-9]*)$ ]]; then
        return 1
    fi
    printf '%s' "${BASH_REMATCH[1]}"
}

#######################################
# resolve_trusted_shas: Set the PR's real base/head SHAs (never taken from the report)
#
# Globals:
#   PR_BASE_SHA / PR_HEAD_SHA - Optional seeds (test seam; both must be set to skip gh)
#   GITHUB_REPOSITORY, GH_TOKEN / GITHUB_TOKEN
#   REVIEW_BASE_SHA (set), REVIEW_HEAD_SHA (set)
#
# Arguments:
#   $1 - PR number
#
# Outputs:
#   None
#
# Returns:
#   0 when both SHAs are 40-hex and the base commit is available locally
#   (fetched from origin when missing), 1 otherwise
#
# Usage:
#   resolve_trusted_shas 7 || warn "..."
#
#######################################
function resolve_trusted_shas {
    local pr_number="$1"
    local base="${PR_BASE_SHA:-}" head="${PR_HEAD_SHA:-}" pr_json

    if [[ -z ${base} || -z ${head} ]]; then
        pr_json="$(GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}" gh pr view "${pr_number}" --repo "${GITHUB_REPOSITORY}" \
            --json baseRefOid,headRefOid 2> /dev/null)" || return 1
        base="$(jq -r '.baseRefOid // ""' <<< "${pr_json}" 2> /dev/null)" || return 1
        head="$(jq -r '.headRefOid // ""' <<< "${pr_json}" 2> /dev/null)" || return 1
    fi
    [[ ${base} =~ ^[0-9a-f]{40}$ && ${head} =~ ^[0-9a-f]{40}$ ]] || return 1

    if ! git cat-file -e "${base}^{commit}" 2> /dev/null; then
        git fetch --no-tags --quiet origin "${base}" > /dev/null 2>&1 || return 1
        git cat-file -e "${base}^{commit}" 2> /dev/null || return 1
    fi
    REVIEW_BASE_SHA="${base}"
    REVIEW_HEAD_SHA="${head}"
}

#######################################
# safe_relative_path: Return whether a path is relative and stays inside its root
#
# Globals:
#   None
#
# Arguments:
#   $1 - Path
#
# Outputs:
#   None
#
# Returns:
#   0 when the path is non-empty, relative, single-line, and has no .. segment
#
# Usage:
#   safe_relative_path "docs/a.md"
#
#######################################
function safe_relative_path {
    local path="$1"

    [[ -n ${path} && ${path} != /* && ${path} != *$'\n'* ]] || return 1
    [[ /${path}/ != */../* ]]
}

#######################################
# validate_finding: Check a finding's shape and verify rule/criteria evidence at the base commit
#
# Globals:
#   REVIEW_BASE_SHA - Trusted base commit; quotes must be exact substrings of the blob there
#
# Arguments:
#   $1 - Finding JSON
#
# Outputs:
#   None
#
# Returns:
#   0 when the finding is kept, 1 when it must be dropped
#
# Usage:
#   if validate_finding "${finding}"; then ...
#
#######################################
function validate_finding {
    local finding="$1"
    local kind location_path evidence_path

    jq -e '
        def pos_int: type == "number" and . >= 1 and . == floor;
        def text: type == "string" and length > 0;
        type == "object"
        and (.severity | IN("Critical", "Warning", "Suggestion"))
        and (.title | text)
        and (.impact | text)
        and (.evidence | type) == "object"
        and (.evidence.kind | IN("rule", "criteria", "bug"))
        and (.location | type) == "object"
        and (.location.path | text)
        and (.location.line | pos_int)
        and ((.location.side // "RIGHT") | IN("RIGHT", "LEFT"))
        and (.location.start_line == null
            or ((.location.start_line | pos_int) and .location.start_line < .location.line))
        and (if .evidence.kind == "bug" then true
            else (.evidence.path | text) and (.evidence.quote | text) end)
    ' <<< "${finding}" > /dev/null 2>&1 || return 1

    location_path="$(jq -r '.location.path' <<< "${finding}")"
    safe_relative_path "${location_path}" || return 1

    kind="$(jq -r '.evidence.kind' <<< "${finding}")"
    if [[ ${kind} == "bug" ]]; then
        return 0
    fi

    evidence_path="$(jq -r '.evidence.path' <<< "${finding}")"
    base_evidence_blob "${evidence_path}" \
        | jq -Rse --argjson f "${finding}" '. as $content | $content | contains($f.evidence.quote)' \
            > /dev/null 2>&1
}

#######################################
# validate_report: Check the report envelope (PR number, premises, findings array)
#   Report SHAs are not trusted; main replaces them with resolve_trusted_shas values.
#
# Globals:
#   None
#
# Arguments:
#   $1 - Report JSON
#   $2 - Expected PR number
#
# Outputs:
#   None
#
# Returns:
#   0 when the envelope is usable, 1 otherwise
#
# Usage:
#   validate_report "${report}" 7
#
#######################################
function validate_report {
    jq -e --argjson n "$2" '
        type == "object"
        and .pr_number == $n
        and (.findings | type) == "array"
        and ((.premises // {}) | type) == "object"
        and ((.summary // "") | type) == "string"
    ' <<< "$1" > /dev/null 2>&1
}

#######################################
# warn: Emit a GitHub Actions warning annotation
#
# Globals:
#   None
#
# Arguments:
#   $1 - Message
#
# Outputs:
#   ::warning:: line to stdout
#
# Returns:
#   0
#
# Usage:
#   warn "report not found"
#
#######################################
function warn {
    printf '::warning::render_review: %s\n' "$1"
}

#######################################
# main: Validate the report and write review.json when VERDICT is APPROVE
#
# Globals:
#   VERDICT, TARGET_JSON, GITHUB_REPOSITORY, LOOP_MESSAGE_DIR, PR_DIFF_FILE,
#   REVIEW_BASE_SHA / REVIEW_HEAD_SHA (set)
#
# Arguments:
#   None
#
# Outputs:
#   ${LOOP_MESSAGE_DIR}/review.json; log lines and ::warning:: annotations to stdout
#
# Returns:
#   0 (never fails finalize)
#
# Usage:
#   main
#
#######################################
function main {
    local pr_number report annotated work_dir kept inline_count message_dir review_file

    if [[ ${VERDICT:-} != "APPROVE" ]]; then
        echo "render_review: VERDICT=${VERDICT:-} (not APPROVE); nothing to render"
        return 0
    fi
    message_dir="${LOOP_MESSAGE_DIR:-}"
    if [[ -z ${message_dir} ]]; then
        warn "LOOP_MESSAGE_DIR is not set; review not rendered"
        return 0
    fi
    if ! command -v jq &> /dev/null; then
        warn "jq is required; review not rendered"
        return 0
    fi
    if [[ ! ${GITHUB_REPOSITORY:-} =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
        warn "GITHUB_REPOSITORY is missing or invalid; review not rendered"
        return 0
    fi
    if ! pr_number="$(resolve_pr_number "${TARGET_JSON:-}")"; then
        warn "TARGET_JSON has no entity:pr:<n> handoff key; review not rendered"
        return 0
    fi
    if ! report="$(read_report ".loop-review/pr-${pr_number}.json")" || [[ -z ${report} ]]; then
        warn "report .loop-review/pr-${pr_number}.json could not be read; review not rendered"
        return 0
    fi
    if ! validate_report "${report}" "${pr_number}"; then
        warn "report for PR #${pr_number} is invalid (JSON, pr_number, premises, or findings); review not rendered"
        return 0
    fi
    if ! resolve_trusted_shas "${pr_number}"; then
        warn "trusted base/head SHAs for PR #${pr_number} unavailable (gh pr view or base commit fetch failed); review not rendered"
        return 0
    fi
    # A head mismatch means the PR moved after the review was written: line numbers may land on
    # the wrong lines, so fail closed. A base mismatch is only a warning (evidence is verified
    # at the trusted base regardless).
    if [[ "$(jq -r '.head_sha // "" | tostring' <<< "${report}")" != "${REVIEW_HEAD_SHA}" ]]; then
        warn "report head_sha does not match the PR head (${REVIEW_HEAD_SHA}) for PR #${pr_number}; review not rendered"
        return 0
    fi
    if [[ "$(jq -r '.base_sha // "" | tostring' <<< "${report}")" != "${REVIEW_BASE_SHA}" ]]; then
        warn "report base_sha differs from PR #${pr_number} base (${REVIEW_BASE_SHA}); using the PR's base SHA"
    fi
    report="$(jq -c --arg b "${REVIEW_BASE_SHA}" --arg h "${REVIEW_HEAD_SHA}" '.base_sha = $b | .head_sha = $h' <<< "${report}")"

    work_dir="$(mktemp -d)"
    # shellcheck disable=SC2064
    trap "rm -rf '${work_dir}'" EXIT

    if [[ -z ${PR_DIFF_FILE:-} ]]; then
        PR_DIFF_FILE="${work_dir}/pr.diff"
        if ! GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}" gh pr diff "${pr_number}" --repo "${GITHUB_REPOSITORY}" \
            > "${PR_DIFF_FILE}" 2> /dev/null; then
            rm -f "${PR_DIFF_FILE}"
        fi
    fi
    if [[ ! -r ${PR_DIFF_FILE} ]]; then
        warn "PR #${pr_number} diff unavailable; in-diff findings move to the review body"
    fi

    annotated="$(annotate_report "${report}")"
    kept="$(jq -r '.findings | length' <<< "${annotated}")"
    inline_count="$(jq -r '[.findings[] | select(.inline)] | length' <<< "${annotated}")"
    echo "render_review: PR #${pr_number} findings kept=${kept} inline=${inline_count} dropped=$(jq -r '.dropped' <<< "${annotated}")"

    # Build in the work dir, then move into place: a failed build never leaves a partial review.json
    build_review_json "${annotated}" > "${work_dir}/review.json"
    mkdir -p "${message_dir}"
    review_file="${message_dir}/review.json"
    mv "${work_dir}/review.json" "${review_file}"
    echo "render_review: wrote ${review_file} for PR #${pr_number}"
    return 0
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    # Run main in a subshell outside any conditional context so set -e still aborts it on an
    # unexpected failure; the parent turns that into a warning and always exits 0 (finalize
    # must not fail). inherit_errexit keeps set -e active inside command substitutions.
    shopt -s inherit_errexit
    set +e
    (
        set -e
        main "$@"
    )
    main_status=$?
    if [[ ${main_status} -ne 0 ]]; then
        printf '::warning::render_review: unexpected failure (exit %s); review not rendered\n' "${main_status}"
    fi
    exit 0
fi
