### 1. Global / Base (G)

**G-01: No Hardcoded Secrets**

Check: Are API keys, passwords, and tokens not embedded in source code?
Why: Embedded secrets cause security breaches, credential leakage, audit violations
Fix: Use environment variables or AWS Secrets Manager, remove constants

**G-02: Appropriate Function Signatures**

Check: Are argument count (4+), return types, and bool return overuse appropriate?
Why: Too many arguments and unclear return values cause API misuse, reduced readability, increased maintenance cost
Fix: Use argument structs, avoid named returns, place error return last

**G-03: Leverage Standard Library**

Check: Are external dependencies avoided for features implementable with standard library?
Why: Unnecessary external dependencies increase vulnerability risk, dependency count, maintenance burden
Fix: Prioritize standard library like net/http, encoding/json

**G-04: Appropriate Log Levels**

Check: Are Debug/Info/Warn/Error levels appropriate and structured logging used?
Why: Mixed log levels and unstructured logs make troubleshooting difficult, monitoring inadequate
Fix: Use structured logging libraries (zap/zerolog), unify levels, mask sensitive information

**G-05: Declaration Order (File Level)**

Check: Is order const→var→type (interface→struct)→func (constructor→methods→helpers)?
Why: Inconsistent declaration order reduces readability, increases review oversight risk
Fix: Maintain const→var→type→func order at file level

**G-06: Declaration Order (Within Groups)**

Check: Is each group sorted A→Z alphabetically (recommended)?
Why: Inconsistency within same category makes diff tracking difficult, causes inconsistencies, reduces readability
Fix: A→Z order within groups (recommended), allow grouping related declarations
