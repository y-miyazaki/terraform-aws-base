# Terraform Validation - Troubleshooting Guide

## terraform fmt Failures

**Issue**: Code not formatted

**Fix**: `bash terraform-validation/scripts/validate.sh --fix`

## terraform validate Failures

**Common issues**:
- Missing required arguments
- Invalid resource references
- Type mismatches

**Fix**: Read error message and correct configuration

## tflint Failures

**Common issues**:
- Deprecated syntax
- Best practice violations

**Fix**: Update code according to suggestions

## trivy config Failures

**Common security issues**:
- Unencrypted S3 buckets
- Overly permissive IAM policies
- Missing KMS encryption
- Public access enabled

**Fix**: Add security controls as recommended
