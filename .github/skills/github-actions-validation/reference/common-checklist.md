# GitHub Actions Validation Checklist

## Syntax Validation

- SYNTAX-01: Valid YAML structure
- SYNTAX-02: No parsing errors
- SYNTAX-03: Required fields present
- SYNTAX-04: Proper indentation

## Security Checks

- SEC-01: Secret handling correct
- SEC-02: Permissions minimized
- SEC-03: Third-party actions verified
- SEC-04: No hardcoded credentials

## Best Practices

- BP-01: Workflow naming clear
- BP-02: Job dependencies explicit
- BP-03: Step ordering correct
- BP-04: Timeout values set
- BP-05: Error handling configured

## Triggers & Conditions

- TRIG-01: Trigger scope appropriate
- TRIG-02: Conditions clear
- TRIG-03: Concurrency configured (if needed)
- TRIG-04: Matrix strategy valid

## Tool Integration

- TOOL-01: actionlint pass
- TOOL-02: ghalint pass
- TOOL-03: zizmor pass
