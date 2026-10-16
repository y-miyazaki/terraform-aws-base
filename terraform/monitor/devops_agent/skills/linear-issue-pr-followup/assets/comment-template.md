<!--
Answer comment template for linear-issue-pr-followup.
Load ONLY when posting an answer comment. Keep the labels `Checked:`, `Changed:`, `Not done:`, `Closed:` in English; write the prose in the language of the Issue or PR.
-->

<answer to each unanswered comment; do not @-mention anyone>

<!-- include only the lines that apply -->

Checked: <what was re-checked read-only, with the result and timestamp>
<!-- example: Checked: CloudWatch alarm `OrderServiceLatency` — currently in OK state as of 2026-10-13T11:00Z. -->

Changed: <file as `<owner>/<repo>:<path>` (link when verified), and reason, or the Issue/PR text that was updated>
<!-- example: Changed: [acme/infra:terraform/alarms.tf](https://github.com/acme/infra/blob/develop/terraform/alarms.tf) — raised threshold from 500 ms to 800 ms per the request. -->

Not done: <what was not done and why; what a human must do>
<!-- example: Not done: Cannot update the IAM policy; a human must apply this change manually via the AWS console. -->

Closed: <which auto-close condition was met and what action was taken>
<!-- Use this line ONLY when closing the Issue or PR in this comment. Include the condition (AUTO-C1/C2/C3/C4 or AUTO-I1/I2) and a brief reason.
     examples:
       Closed: AUTO-C1 — the linked Linear Issue is already closed; closing this PR as not_planned.
       Closed: AUTO-C2 — fix was applied in commit abc123 outside this PR; closing as not_planned.
       Closed: AUTO-C3 — reviewer stated no fix is needed ("false positive"); closing as not_planned.
       Closed: AUTO-I1 — closing this Issue per explicit instruction; marked canceled.
-->

-- devops-agent
