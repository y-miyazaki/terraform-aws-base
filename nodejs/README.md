# Node.js Modules

This directory contains development and validation instructions for Lambda-oriented Node.js modules.

## Target Modules

- `s3_notification_s3_object_created_for_athena`
- `kinesis_data_firehose_cloudwatch_logs_processor`

## Security Fix Policy

To address vulnerabilities reported by `npm audit` (including `fast-xml-parser`), the following controls are applied:

- Pin AWS SDK clients to explicit versions.
- Force a patched parser version with `overrides`.

### Pinned Dependencies

- `s3_notification_s3_object_created_for_athena`
  - `@aws-sdk/client-s3`: `3.1011.0`
- `kinesis_data_firehose_cloudwatch_logs_processor`
  - `@aws-sdk/client-firehose`: `3.1011.0`
  - `@aws-sdk/client-kinesis`: `3.1011.0`

### Override

- `fast-xml-parser`: `5.5.6`

## Validation Steps

### 1. Run Full Validation

```bash
/workspace/scripts/nodejs/validate.sh -f
```

Expected result:

- `Projects passed: 2`
- `Projects failed: 0`

### 2. Run Local Tests (`test-local.js`)

Make sure AWS credentials are configured in your local environment before running tests.
Do not commit profile names, account IDs, or credential values into this repository.

#### kinesis_data_firehose_cloudwatch_logs_processor

```bash
cd /workspace/nodejs/kinesis_data_firehose_cloudwatch_logs_processor
npm test
```

#### s3_notification_s3_object_created_for_athena

```bash
cd /workspace/nodejs/s3_notification_s3_object_created_for_athena
npm test
```

## Notes

- Run `npm audit --audit-level=high` after dependency changes.
- Update `package-lock.json` whenever `package.json` changes.
