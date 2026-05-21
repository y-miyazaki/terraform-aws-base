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

**Resolution**: This is expected behavior. Archive the finding. See [design-decisions.md](./design-decisions.md) for the KMS key policy rationale.

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

**Cause**: When the primary region is `us-east-1`, the `_us_east_1` variant resources would duplicate the primary resources.

**Resolution**: This is handled automatically by the guard in `locals.tf`:

```hcl
locals {
  is_default_region_us_east_1 = var.region == "us-east-1"
  is_enabled_us_east_1        = !local.is_default_region_us_east_1 && var.us_east_1.is_enabled
}
```

If duplication occurs, verify that `var.region` is correctly set in the tfvars file.

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

- [specification.md](./specification.md) — Validation and safety checks
- [architecture.md](./architecture.md) — Directory layout and multi-region pattern
- [design-decisions.md](./design-decisions.md) — Rationale for expected Access Analyzer findings
