# Shell Script Validation - Script Standards

## Required Template

```bash
#!/bin/bash
set -euo pipefail
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"
```

## Function Order

1. show_usage / parse_arguments (if present)
2. Other functions in alphabetical order
3. main function last

## Error Handling

- Use error_exit from common library
- Set up cleanup trap for temporary files
- Validate all inputs

See main [SKILL.md](../SKILL.md) for comprehensive validation workflow.
