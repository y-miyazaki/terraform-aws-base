## 2. Error Handling (ERR)

**ERR-01: Careful Use of continue-on-error**

Check: Is `continue-on-error` usage justified and limited?
Why: Overusing `continue-on-error` causes hidden failures to be overlooked
Fix: Limit usage, explicitly document justification in comments

**ERR-02: Failure Post-Processing Preparation**

Check: Is post-processing (log collection, cleanup) prepared for failures?
Why: Missing failure post-processing makes analysis difficult, leaves resources behind
Fix: Collect logs/artifacts and perform cleanup with `if: failure()`

**ERR-03: Failure Notification Integration**

Check: Are notifications configured for critical job failures?
Why: Missing failure notifications cause failures to be missed, delay response
Fix: Implement Slack/Email notifications, aggregate by severity

**ERR-04: Job Timeout Configuration**

Check: Is appropriate `timeout-minutes` set for each job?
Why: Missing timeout settings waste runners, stall CI
Fix: Set appropriate `timeout-minutes`
