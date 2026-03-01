### 6. Error Handling (ERR)

**ERR-01: Appropriate Error Wrapping**

Check: Are errors wrapped with fmt.Errorf("%w", err) and context information included?
Why: Returning only error strings makes debugging difficult, lacks stack traces, root cause unclear
Fix: Wrap with fmt.Errorf("%w", err), add context information

**ERR-02: Appropriate Custom Error Definition**

Check: Are sentinel errors defined and custom errors compatible with errors.Is/As?
Why: String-only errors make error handling branching difficult, retry determination impossible
Fix: Define custom errors compatible with errors.Is/As, define sentinel errors, use errors.Is checks

**ERR-03: Avoid and Recover from Panics**

Check: Are panics only for fatal errors and defer+recover implemented?
Why: Panic overuse and missing recover cause sudden application termination, data inconsistency
Fix: Panic only for fatal errors, implement defer+recover, return error for normal errors

**ERR-04: Appropriate Error Log Information**

Check: Are error log levels unified, stack traces recorded, and sensitive information masked?
Why: Inconsistent log levels and sensitive information make failure analysis difficult, security risks
Fix: Unify Error/Warn levels, record stack traces, mask sensitive information

**ERR-05: Error Propagation to Upper Layers**

Check: Are errors not swallowed and error context preserved?
Why: Swallowed errors prevent failure detection, root cause tracking impossible
Fix: Always return errors, wrap preserving context, appropriate logging

**ERR-06: Error Handling Strategy**

Check: Are error classifications defined, retry logic, and Fail Fast implemented?
Why: Inconsistent error handling policies cause missing retries, failure expansion, delayed recovery
Fix: Define error classifications, identify retryable errors, implement Circuit Breaker

**ERR-07: External Dependency Error Handling**

Check: Are timeouts set, retries implemented, and errors classified?
Why: Missing timeouts and retries cause infinite waits, failure propagation
Fix: Set context timeout, exponential backoff, classify transient/permanent errors

**ERR-08: Validation Errors**

Check: Are input validations, field-level errors, and user-friendly messages present?
Why: Insufficient input validation and unclear error messages increase support costs, confuse users
Fix: Implement struct tag validation, field-level errors, clear messages

**ERR-09: Error Message Security**

Check: Are there no internal implementation exposure, external stack trace disclosure, or SQL statement exposure?
Why: Internal information exposure causes information leakage, provides attack clues, security risks
Fix: Separate user-facing messages and internal logs, don't disclose detailed information
