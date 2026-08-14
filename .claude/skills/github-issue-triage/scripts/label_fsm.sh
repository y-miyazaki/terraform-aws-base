#!/bin/bash
#######################################
# Description: Allowlisted label catalog + triage FSM helpers for github-issue-triage
#
# Usage: source "${SCRIPT_DIR}/label_fsm.sh"
#
# Design Rules:
# - Load allowlisted labels only from scripts/labels.json
# - Use jq for FSM transitions; no network or gh calls in this library
# - Safe to source from detect scripts; do not enable set -euo here
#
# Note: Lives beside detect scripts (not under scripts/lib/) so
# scripts/self/apm/sync_skill_lib.sh does not overwrite it.
#######################################

LABEL_FSM_CATALOG_PATH="${LABEL_FSM_CATALOG_PATH:-}"

#######################################
# label_fsm_load_catalog: Validate and remember catalog path
#
# Globals:
#   LABEL_FSM_CATALOG_PATH - Updated in place when validation succeeds
#
# Arguments:
#   $1 - Path to labels.json catalog
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on invalid path or JSON
#
#######################################
function label_fsm_load_catalog {
    local path="$1"
    if [[ -z ${path} || ! -f ${path} ]]; then
        echo "label_fsm_load_catalog: catalog path required" >&2
        return 1
    fi
    if ! jq -e 'type == "object"' "${path}" > /dev/null 2>&1; then
        echo "label_fsm_load_catalog: catalog must be a JSON object" >&2
        return 1
    fi
    LABEL_FSM_CATALOG_PATH="${path}"
}

#######################################
# label_fsm_is_allowlisted: Exit 0 when name is in catalog
#
# Globals:
#   LABEL_FSM_CATALOG_PATH - Catalog loaded by label_fsm_load_catalog
#
# Arguments:
#   $1 - Label name
#
# Outputs:
#   None
#
# Returns:
#   0 when allowlisted, 1 otherwise
#
#######################################
function label_fsm_is_allowlisted {
    local name="$1"
    if [[ -z ${LABEL_FSM_CATALOG_PATH} || -z ${name} ]]; then
        return 1
    fi
    jq -e --arg name "${name}" 'has($name)' "${LABEL_FSM_CATALOG_PATH}" > /dev/null 2>&1
}

#######################################
# label_fsm_label_present: Exit 0 when name is in labels JSON array
#
# Globals:
#   None
#
# Arguments:
#   $1 - Label name
#   $2 - Current labels JSON array
#
# Outputs:
#   None
#
# Returns:
#   0 when present, 1 otherwise
#
#######################################
function label_fsm_label_present {
    local name="$1"
    local labels_json="$2"
    jq -e --arg name "${name}" 'contains([$name])' <<< "${labels_json}" > /dev/null 2>&1
}

#######################################
# label_fsm_print_transition: Print {"add":[],"remove":[]} JSON
#
# Globals:
#   None
#
# Arguments:
#   $1 - Nameref to add label array
#   $2 - Nameref to remove label array
#
# Outputs:
#   Transition JSON on stdout
#
# Returns:
#   0 on success
#
#######################################
function label_fsm_print_transition {
    local -n _add_ref=$1
    local -n _remove_ref=$2
    local add_json remove_json
    if [[ ${#_add_ref[@]} -eq 0 ]]; then
        add_json='[]'
    else
        add_json="$(printf '%s\n' "${_add_ref[@]}" | jq -R . | jq -sc .)"
    fi
    if [[ ${#_remove_ref[@]} -eq 0 ]]; then
        remove_json='[]'
    else
        remove_json="$(printf '%s\n' "${_remove_ref[@]}" | jq -R . | jq -sc .)"
    fi
    jq -nc --argjson add "${add_json}" --argjson remove "${remove_json}" '{add:$add,remove:$remove}'
}

#######################################
# label_fsm_next_state: Recommend add/remove for an FSM event
#
# Globals:
#   None
#
# Arguments:
#   $1 - Current labels JSON array
#   $2 - FSM event name
#
# Outputs:
#   Transition JSON on stdout
#
# Returns:
#   0 on success, 1 on unknown event
#
#######################################
function label_fsm_next_state {
    local labels_json="$1"
    local event="$2"
    local -a add=()
    local -a remove=()

    case "${event}" in
        opened)
            if ! label_fsm_label_present "needs-triage" "${labels_json}"; then
                add+=("needs-triage")
            fi
            ;;
        mark_needs_info)
            if ! label_fsm_label_present "triage:needs-info" "${labels_json}"; then
                add+=("triage:needs-info")
            fi
            if label_fsm_label_present "triage:ready" "${labels_json}"; then
                remove+=("triage:ready")
            fi
            ;;
        mark_ready)
            if ! label_fsm_label_present "triage:ready" "${labels_json}"; then
                add+=("triage:ready")
            fi
            if label_fsm_label_present "triage:needs-info" "${labels_json}"; then
                remove+=("triage:needs-info")
            fi
            if label_fsm_label_present "needs-triage" "${labels_json}"; then
                remove+=("needs-triage")
            fi
            ;;
        human_retriage)
            if label_fsm_label_present "triage:ready" "${labels_json}"; then
                remove+=("triage:ready")
            fi
            if ! label_fsm_label_present "needs-triage" "${labels_json}"; then
                add+=("needs-triage")
            fi
            ;;
        *)
            echo "label_fsm_next_state: unknown event: ${event}" >&2
            return 1
            ;;
    esac

    label_fsm_print_transition add remove
}

#######################################
# label_fsm_ensure_labels_exist: Catalog names missing from existing JSON array
#
# Globals:
#   LABEL_FSM_CATALOG_PATH - Catalog loaded by label_fsm_load_catalog
#
# Arguments:
#   $1 - Existing labels JSON array
#
# Outputs:
#   JSON array of missing catalog names on stdout
#
# Returns:
#   0 on success, 1 when catalog is not loaded
#
#######################################
function label_fsm_ensure_labels_exist {
    local existing_json="$1"
    if [[ -z ${LABEL_FSM_CATALOG_PATH} ]]; then
        echo "label_fsm_ensure_labels_exist: catalog not loaded" >&2
        return 1
    fi
    jq -nc --argjson existing "${existing_json}" --slurpfile catalog "${LABEL_FSM_CATALOG_PATH}" '
      ($catalog[0] | keys_unsorted) as $want
      | [$want[] | select(. as $n | ($existing | index($n) | not))]
    '
}
