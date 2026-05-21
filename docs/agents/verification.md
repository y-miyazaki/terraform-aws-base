# Verification Requirements

Standards for verifying work performed by AI agents.

## Mandatory Verification

Perform verification appropriate to the task and risk level.

Examples: linting, testing, schema validation, runtime validation, static analysis, build verification, configuration validation.

If expected verification cannot be performed:

- explicitly explain why
- describe residual risks

## Verification Reporting

When verification is incomplete or partial:

- explain limitations
- explain residual risks
- explain why the current state is considered acceptable

## Uncertainty Handling

- Clearly distinguish verified facts from assumptions
- Explicitly state when behavior has not been validated
- Avoid presenting unverified behavior as confirmed

When uncertain:

- explain uncertainty
- explain verification limitations
- propose safe verification steps

## Test Integrity

MUST NOT:

- weaken tests solely to make them pass
- remove failing tests without justification
- bypass validations without explaining rationale

When tests fail, determine whether:

- implementation is incorrect
- expectations are outdated
- environment or fixtures are invalid
