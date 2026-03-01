### 7. Security (SEC)

**SEC-01: Input Validation**

Check: Are input validation, prepared statements, and sanitization implemented?
Why: Unvalidated input and SQL string concatenation enable SQL injection, XSS attacks, data tampering
Fix: Mandatory prepared statements, implement validation, implement sanitization

**SEC-02: Output Sanitization**

Check: Are HTML escaping, JSON injection prevention, and CRLF injection prevention present?
Why: Missing escaping causes XSS vulnerabilities, response tampering, session hijacking
Fix: Use html/template, context-appropriate escaping for output

**SEC-03: Appropriate Encryption**

Check: Are TLS 1.2+, AES-256-GCM, and crypto/rand used?
Why: Plaintext communication and weak encryption enable eavesdropping, MITM attacks, data leakage
Fix: Mandatory TLS 1.2+, use AES-256-GCM, use crypto/rand

**SEC-04: Authentication and Authorization Implementation**

Check: Are all endpoints authenticated, JWT signature verified, and RBAC implemented?
Why: Skipped authentication and insufficient verification enable unauthorized access, privilege escalation, data leakage
Fix: Mandatory authentication for all endpoints, JWT signature verification, RBAC implementation

**SEC-05: Rate Limiting and DOS Prevention**

Check: Are rate limiters, timeout settings, and request size limits present?
Why: Missing request limits enable DOS attacks, service outages, resource exhaustion
Fix: Implement rate limiter, set timeouts, limit request sizes

**SEC-06: Log Security**

Check: Are sensitive information masking functions and password/token masking present?
Why: Logging passwords and tokens causes credential leakage, GDPR violations
Fix: Implement sensitive information masking functions, structured logging, log rotation

**SEC-07: Secure Defaults**

Check: Are least privilege principle, production debug disabled, and explicit CORS settings present?
Why: Insecure defaults cause security breaches, increased attack success rate
Fix: Least privilege principle, disable production debug, explicit CORS settings

**SEC-08: OWASP Compliance**

Check: Are OWASP Top 10 addressed, Security Headers set, and CSP configured?
Why: OWASP non-compliance leaves known vulnerabilities, increases attack risk
Fix: Check OWASP Top 10, set Security Headers, regular assessments
