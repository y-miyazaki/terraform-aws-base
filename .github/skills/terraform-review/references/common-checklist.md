# Terraform Code Review Checklist

## Global & Base

- G-01: Secret hardcoding prohibition
- G-02: Terraform versioning (required_version)
- G-03: Provider versioning (version constraints)
- G-04: for_each vs. count pattern choice

## Module Design

- MOD-01: Module responsibility separation
- MOD-02: Input variable organization
- MOD-03: Output design and sensitivity
- MOD-04: Module composition and nesting

## Variables & Defaults

- VAR-01: Variable type safety
- VAR-02: Default value appropriateness
- VAR-03: Validation rules for inputs
- VAR-04: Sensitive variable marking

## Security

- SEC-01: IAM policy least privilege
- SEC-02: Resource policy conditions
- SEC-03: Encryption configuration
- SEC-04: VPC and network isolation
- SEC-05: Secrets management

## State Management

- STATE-01: Backend configuration
- STATE-02: State locking
- STATE-03: Remote state access control
- STATE-04: Sensitive data in state

## Tagging & Naming

- TAG-01: Consistent tagging strategy
- TAG-02: Environment tags
- TAG-03: Naming conventions
- TAG-04: Cost allocation tags

## Documentation

- DOC-01: Resource documentation
- DOC-02: Variable descriptions
- DOC-03: Output descriptions
- DOC-04: Module README

## Architecture

- ARCH-01: Modularity principle
- ARCH-02: Environment separation
- ARCH-03: Dependency management
- ARCH-04: Design pattern compliance

## Monitoring & Logging

- MON-01: CloudWatch alarms
- MON-02: Logging configuration
- LOG-01: Log retention policies

## Performance

- PERF-01: Resource sizing
- PERF-02: Read capacity (RDS, DynamoDB)
- PERF-03: Auto-scaling configuration
