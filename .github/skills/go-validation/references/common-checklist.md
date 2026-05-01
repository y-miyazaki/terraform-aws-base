# Go Validation Checklist

## Execution Order

Run tools in this order (fail-fast: stop on first failure):

1. `go mod tidy` — dependency consistency check
2. `go fmt` — formatting compliance
3. `go vet` — static analysis
4. `golangci-lint` — linting and style checks
5. `go test` — unit tests and race condition detection
6. `govulncheck` — known vulnerability scan

## Checks by Tool

### go mod tidy
- MOD-01: go.mod and go.sum are consistent with source imports
- MOD-02: No extraneous or missing dependencies

### go fmt
- FMT-01: All .go files are gofmt-formatted
- FMT-02: Import blocks organized per goimports conventions

### go vet
- VET-01: No static analysis errors reported
- VET-02: No type-safety violations detected
- VET-03: No suspicious constructs (unreachable code, printf mismatches)

### golangci-lint
- LINT-01: All enabled linters pass with zero findings
- LINT-02: No style violations above configured severity
- LINT-03: Cyclomatic complexity within threshold
- LINT-04: No deprecated constructs used

### go test
- TEST-01: All tests pass (exit code 0)
- TEST-02: Race detector reports no races (`-race` flag)
- TEST-03: Coverage meets project threshold
- TEST-04: No test binary build errors

### govulncheck
- SEC-01: No known vulnerabilities in direct or transitive dependencies
- SEC-02: All flagged CVEs reviewed and acknowledged if suppressed

## Pass Criteria

- All tools exit with code 0
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
