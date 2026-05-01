# Diagram as Code (DAC) Validation Checklist

## Execution Order

Run tools in this order (fail-fast: stop on first failure):

1. `yamllint` — YAML syntax and formatting check
2. `awsdac` — DAC schema validation and PNG generation
3. File verification — confirm output PNG exists and is non-empty

## Checks by Tool

### yamllint
- YAML-01: File parses as valid YAML without errors
- YAML-02: Indentation is consistent (2-space)
- YAML-03: No duplicate keys at any level
- YAML-04: Trailing spaces and document-end markers comply with `.yamllint` config

### awsdac
- DAC-01: Top-level `Diagram` block is present with required fields
- DAC-02: All referenced AWS resource types are recognized by awsdac
- DAC-03: Resource IDs are unique within the diagram
- DAC-04: All `Links` endpoints reference declared resource IDs
- DAC-05: `awsdac` exits with code 0 and produces a PNG file

### File verification
- FILE-01: Output PNG file exists at the expected path
- FILE-02: PNG file size is greater than 0 bytes
- FILE-03: Output filename matches the input YAML filename (extension replaced)

## Pass Criteria

- All tools exit with code 0
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
