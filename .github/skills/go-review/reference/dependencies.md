### 12. Dependencies (DEP)

**DEP-01: Explicit Direct Dependencies**

Check: Are direct dependencies explicitly in go.mod, versions pinned, and regularly updated?
Why: Depending on indirect dependencies and unpinned versions cause unstable builds, unexpected behavior
Fix: Explicitly list direct dependencies in go.mod, pin versions, regular updates

**DEP-02: Dependency Update Strategy**

Check: Are regular go get -u, Renovate/Dependabot adoption, and update policies established?
Why: No dependency updates and neglected vulnerabilities cause security risks, technical debt
Fix: Regular go get -u, adopt Renovate/Dependabot, establish update policy

**DEP-03: vendor Management (Only When Necessary)**

Check: Is vendor only when necessary, .gitignore configured, and module proxy utilized?
Why: Unnecessary vendor use and missing commits increase repository size, CI time
Fix: vendor only when necessary, configure .gitignore, utilize module proxy

**DEP-04: Prioritize Standard Library**

Check: Is standard library prioritized, minimal dependency principle followed, and dependency reasons clarified?
Why: External dependencies for standard-implementable features increase vulnerability risk, maintenance cost
Fix: Prioritize standard library, follow minimal dependency principle, clarify dependency reasons

**DEP-05: AWS SDK Version Management**

Check: Are AWS SDK v2 migration, latest version usage, and deprecated API replacement done?
Why: Old AWS SDK versions and v1/v2 mixing prevent new feature usage, deprecated warnings
Fix: Migrate to AWS SDK v2, use latest version, replace deprecated APIs

**DEP-06: Separate Development Dependencies**

Check: Are //go:build tools used, development dependencies clarified, and production excluded?
Why: Development dependencies in production and unnecessary dependencies cause security risks, increased deployment size
Fix: Use //go:build tools, clarify development dependencies, exclude from production

**DEP-07: License Compatibility**

Check: Are go-licenses utilized, license lists generated, and compatibility verified?
Why: Unverified licenses and restrictive libraries like GPL cause legal risks, commercial use impossible
Fix: Utilize go-licenses, generate license lists, verify compatibility

## Best Practices

- **Context-First**: Always start reviews with context handling and concurrency patterns
- **Security Priority**: Prioritize security checks (G, SEC, ERR) to catch critical issues early
- **Performance Aware**: Check hot paths and common performance anti-patterns
- **Test Quality**: Verify test design and coverage complement automated checks
- **Architecture Focus**: Assess long-term maintainability through architecture patterns
