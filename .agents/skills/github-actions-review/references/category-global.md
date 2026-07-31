# Global / Base (G)

**G-01 (SHOULD): Narrow on triggers by branch/path/event**

Check: Are triggers limited to specific branches, paths, or event types rather than triggering on all pushes/PRs?
Why: Overly broad triggers cause unnecessary executions, increase costs, generate noise
Fix: Narrow triggers with `paths`/`types`

**G-02 (SHOULD): Production jobs use environment + approval**

Check: Do production jobs have `environment` configuration and approval?
Why: Missing environment/approval causes accidental production execution, secret leak risks
Fix: Set `environment` for critical jobs, specify approvers
