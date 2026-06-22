# Troubleshooting

Common issues and their resolutions for this Terraform baseline infrastructure repository.

## Terraform Init Fails with Backend Configuration Error

**Cause**: Missing or incorrect `.tfbackend` file for the target environment.

**Resolution**:

```sh
terraform init -backend-config=terraform.<env>.tfbackend
```

Ensure the S3 bucket and DynamoDB table specified in the backend file exist before initialization.

**Prevention**: Always use the environment-specific backend file. Never run `terraform init` without `-backend-config`.

## Provider Version Constraint Conflict

**Cause**: Lock file (`.terraform.lock.hcl`) contains hashes for a different platform or outdated provider version.

**Resolution**:

```sh
rm .terraform.lock.hcl
terraform init -upgrade -backend-config=terraform.<env>.tfbackend
```

**Prevention**: Commit `.terraform.lock.hcl` and run `terraform init -upgrade` when intentionally updating providers.

## GuardDuty Detector Already Exists

**Cause**: A GuardDuty detector was created outside Terraform (e.g., via AWS Console or Control Tower). The external data source script detects the existing detector and skips creation.

**Resolution**:

1. Check existing detectors:

```sh
aws guardduty list-detectors --region <region>
```

2. If the detector should be managed by Terraform, import it:

```sh
terraform import 'module.aws_security_guardduty[0].aws_guardduty_detector.this[0]' <detector-id>
```

3. If managed by Control Tower, set `control_tower.managed_services.guardduty = true` in tfvars.

**Prevention**: Set `control_tower` flags correctly before first apply.

## Access Analyzer Organization Analyzer Conflict

**Cause**: An organization-level Access Analyzer already exists (created by another account or manually). The `check_organization_analyzer.sh` script returns `exists: true`.

**Resolution**:

1. Identify the existing analyzer:

```sh
aws accessanalyzer list-analyzers --type ORGANIZATION --region <region>
```

2. If it should be managed by this Terraform, import it into the audit account state.
3. If managed externally, set `is_enabled = false` for Access Analyzer in the audit tfvars.

## Security Hub Finding: KMS Key Policy "isPublic: true"

**Cause**: CloudTrail KMS key uses `Principal: {"AWS": "*"}` with condition constraints. Access Analyzer flags this as public access.

**Resolution**: This is expected behavior. Archive the finding. See [Design Decisions](../explanation/design-decisions.md) for the KMS key policy rationale.

**Prevention**: Document expected findings in team runbooks and archive them systematically.

## Terraform Plan Shows Unexpected Resource Replacement

**Cause**: Changing certain immutable attributes (e.g., KMS key policy, Lambda runtime) forces resource recreation.

**Resolution**:

1. Review the plan output carefully for `# forces replacement` annotations.
2. If replacement is acceptable, proceed with apply.
3. If replacement is risky (e.g., KMS key deletion), use `lifecycle { prevent_destroy = true }` or adjust the change approach.

```sh
terraform plan -var-file=terraform.<env>.tfvars -out=plan.tfplan
terraform show plan.tfplan
```

## Lambda Function Deployment Package Not Found

**Cause**: Lambda source code under `lambda/` or `nodejs/` has not been built/packaged before `terraform apply`.

**Resolution**:

```sh
cd nodejs/<function_name>
npm install
npm run build
cd ../../terraform/<layer>
terraform apply -var-file=terraform.<env>.tfvars
```

**Prevention**: Run build scripts before apply. CI/CD pipelines should include the build step.

## Multi-Region Resource Duplication When Region is us-east-1

**Cause**: Central services (`main_central_*.tf`) should deploy once. If they accidentally use `for_each` over targets, resources get duplicated.

**Resolution**: Ensure `var.region.global` is not included in `var.region.targets` for services that should only exist once (e.g., Budgets Scheduler, Trusted Advisor Lambda). Regional services (`main_regional_*.tf`) use `for_each = toset(var.region.targets)` and deploy to all target regions — this is expected behavior, not duplication.

If a global service (Scheduler/Lambda) is accidentally deployed to multiple regions, verify the file uses `region = var.region.global` instead of iterating over targets.

## Slack Notifications Not Arriving

**Cause**: Incorrect Slack OAuthToken, ChannelID, or the Slack app has not been added to the target channel.

**Resolution**:

1. Verify the Slack app is installed in the workspace and added to the channel.
2. Confirm `slack_oauth_token` and `slack_channel_id` in tfvars are correct.
3. Check Lambda CloudWatch Logs for error messages:

```sh
aws logs filter-log-events \
  --log-group-name "/aws/lambda/<name_prefix>-<function>" \
  --start-time $(date -d '1 hour ago' +%s000)
```

**Prevention**: Test Slack integration in a non-production channel first.

## TFLint Recursive Fails with Module Errors

**Cause**: TFLint cannot resolve module sources without prior `terraform init`.

**Resolution**:

```sh
terraform init -backend-config=terraform.<env>.tfbackend
tflint --init
tflint --recursive
```

**Prevention**: Always run `terraform init` before linting in CI/CD pipelines.

## Cross-References

- [Terraform Specification](../reference/specification.md) — Validation and safety checks
- [Architecture Overview](../explanation/architecture.md) — Directory layout and multi-region pattern
- [Design Decisions](../explanation/design-decisions.md) — Rationale for expected Access Analyzer findings
