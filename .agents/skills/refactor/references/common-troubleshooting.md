## Troubleshooting

- **Automation: empty/`skip` hints:** Emit no-op report; do not run Phase B.
- **Survey: zero apply candidates:** Emit survey no-op; note in Overview.
- **Apply requested but `may_edit` is `false`:** Survey only; note that edits require explicit apply language or `may_edit: true`.
- **Gate failure for one candidate:** Revert that edit; move row to **Deferred**; continue remaining candidates.
- **Architecture request without `approved_slice`:** Emit proposal only; stop before Phase B.
