# Go Validation - Security Best Practices

## Contents

- [Go Validation - Security Best Practices](#go-validation---security-best-practices)
  - [Contents](#contents)
  - [Overview](#overview)
  - [Security Validation with govulncheck](#security-validation-with-govulncheck)
    - [Understanding govulncheck](#understanding-govulncheck)
    - [Running govulncheck](#running-govulncheck)
    - [Interpreting Results](#interpreting-results)
  - [Input Validation](#input-validation)
    - [Validate All External Input](#validate-all-external-input)
    - [Sanitize User Input](#sanitize-user-input)
  - [Context Usage](#context-usage)
    - [Always Use Context for Timeouts](#always-use-context-for-timeouts)
    - [Cancel Long-Running Operations](#cancel-long-running-operations)
  - [Error Handling](#error-handling)
    - [Don't Expose Sensitive Information](#dont-expose-sensitive-information)
    - [Log Errors Securely](#log-errors-securely)
  - [Cryptography](#cryptography)
    - [Use Standard Library Crypto](#use-standard-library-crypto)
    - [Never Store Secrets in Code](#never-store-secrets-in-code)
  - [SQL Injection Prevention](#sql-injection-prevention)
    - [Use Prepared Statements](#use-prepared-statements)
  - [File Operations](#file-operations)
    - [Secure File Handling](#secure-file-handling)
  - [Race Conditions](#race-conditions)
    - [Thread-Safe Data Access](#thread-safe-data-access)
  - [Denial of Service Prevention](#denial-of-service-prevention)
    - [Limit Resource Consumption](#limit-resource-consumption)
  - [Security Checklist](#security-checklist)
  - [Additional Resources](#additional-resources)
  - [Summary](#summary)

## Overview

This guide provides security best practices for Go code that complement the validation checks.

## Security Validation with govulncheck

### Understanding govulncheck

`govulncheck` scans for known vulnerabilities in:
- Direct dependencies
- Indirect dependencies
- Standard library

**Important**: Only reports vulnerabilities in code paths that are actually used in your program.

### Running govulncheck

```bash
# Basic scan
govulncheck ./...

# JSON output for automation
govulncheck -json ./...

# Show all findings including informational
govulncheck -show verbose ./...
```

### Interpreting Results

```
Vulnerability #1: GO-2024-1234
  Description: SQL injection in database/sql
  Found in: golang.org/x/database@v1.0.0
  Fixed in: golang.org/x/database@v1.1.0
  Example: Call path from main.ProcessQuery to vulnerable function
```

## Input Validation

### Validate All External Input

```go
// Bad - No validation
func ProcessInput(input string) error {
    return processData(input)
}

// Good - Validate input
func ProcessInput(input string) error {
    if input == "" {
        return errors.New("input cannot be empty")
    }
    if len(input) > 1000 {
        return errors.New("input too long")
    }
    if !isValidFormat(input) {
        return errors.New("invalid input format")
    }
    return processData(input)
}
```

### Sanitize User Input

```go
import (
    "html"
    "regexp"
    "strings"
)

// Sanitize HTML input
func SanitizeHTML(input string) string {
    return html.EscapeString(input)
}

// Validate alphanumeric input
func ValidateAlphanumeric(input string) error {
    matched, err := regexp.MatchString(`^[a-zA-Z0-9]+$`, input)
    if err != nil {
        return err
    }
    if !matched {
        return errors.New("input must be alphanumeric")
    }
    return nil
}

// Sanitize file paths
func SanitizeFilePath(path string) (string, error) {
    // Prevent directory traversal
    cleaned := filepath.Clean(path)
    if strings.Contains(cleaned, "..") {
        return "", errors.New("invalid path")
    }
    return cleaned, nil
}
```

## Context Usage

### Always Use Context for Timeouts

```go
// Bad - No timeout
func FetchData(url string) ([]byte, error) {
    resp, err := http.Get(url)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()
    return io.ReadAll(resp.Body)
}

// Good - Use context with timeout
func FetchData(ctx context.Context, url string) ([]byte, error) {
    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, err
    }

    client := &http.Client{
        Timeout: 10 * time.Second,
    }

    resp, err := client.Do(req)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    return io.ReadAll(resp.Body)
}
```

### Cancel Long-Running Operations

```go
func ProcessWithCancellation(ctx context.Context) error {
    // Create cancellable context
    ctx, cancel := context.WithTimeout(ctx, 5*time.Minute)
    defer cancel()

    // Use context in all operations
    select {
    case <-processData(ctx):
        return nil
    case <-ctx.Done():
        return ctx.Err()
    }
}
```

## Error Handling

### Don't Expose Sensitive Information

```go
// Bad - Exposes internal details
func Login(username, password string) error {
    user, err := db.FindUser(username)
    if err != nil {
        return fmt.Errorf("database error: %v", err)
    }
    if user == nil {
        return fmt.Errorf("user %s not found", username)
    }
    if !checkPassword(user, password) {
        return fmt.Errorf("invalid password for user %s", username)
    }
    return nil
}

// Good - Generic error messages
func Login(username, password string) error {
    user, err := db.FindUser(username)
    if err != nil {
        log.Printf("login error for %s: %v", username, err)
        return errors.New("invalid credentials")
    }
    if user == nil || !checkPassword(user, password) {
        return errors.New("invalid credentials")
    }
    return nil
}
```

### Log Errors Securely

```go
import (
    "log/slog"
)

// Good - Structured logging without sensitive data
func ProcessPayment(userID string, amount float64, cardNumber string) error {
    err := chargeCard(cardNumber, amount)
    if err != nil {
        // Log without card number
        slog.Error("payment failed",
            "user_id", userID,
            "amount", amount,
            "error", err,
        )
        return errors.New("payment processing failed")
    }
    return nil
}
```

## Cryptography

### Use Standard Library Crypto

```go
import (
    "crypto/rand"
    "crypto/sha256"
    "encoding/hex"
)

// Generate secure random bytes
func GenerateToken() (string, error) {
    b := make([]byte, 32)
    _, err := rand.Read(b)
    if err != nil {
        return "", err
    }
    return hex.EncodeToString(b), nil
}

// Hash passwords (use bcrypt or argon2)
import "golang.org/x/crypto/bcrypt"

func HashPassword(password string) (string, error) {
    hashed, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
    if err != nil {
        return "", err
    }
    return string(hashed), nil
}

func CheckPassword(password, hash string) bool {
    err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
    return err == nil
}
```

### Never Store Secrets in Code

```go
// Bad - Hardcoded credentials
const dbP = "abcdefg123456"

// Good - Use environment variables
import "os"

func getDBPassword() string {
    password := os.Getenv("DB_PASSWORD")
    if password == "" {
        log.Fatal("DB_PASSWORD environment variable not set")
    }
    return password
}

// Better - Use secrets management
import "github.com/aws/aws-sdk-go-v2/service/secretsmanager"

func getSecret(ctx context.Context, secretID string) (string, error) {
    client := secretsmanager.NewFromConfig(cfg)
    output, err := client.GetSecretValue(ctx, &secretsmanager.GetSecretValueInput{
        SecretId: aws.String(secretID),
    })
    if err != nil {
        return "", err
    }
    return *output.SecretString, nil
}
```

## SQL Injection Prevention

### Use Prepared Statements

```go
import "database/sql"

// Bad - SQL injection vulnerable
func GetUser(db *sql.DB, userID string) (*User, error) {
    query := "SELECT * FROM users WHERE id = " + userID
    row := db.QueryRow(query)
    // ...
}

// Good - Use parameterized queries
func GetUser(db *sql.DB, userID string) (*User, error) {
    query := "SELECT id, name, email FROM users WHERE id = $1"
    row := db.QueryRow(query, userID)

    var user User
    err := row.Scan(&user.ID, &user.Name, &user.Email)
    if err != nil {
        return nil, err
    }
    return &user, nil
}
```

## File Operations

### Secure File Handling

```go
import (
    "io"
    "os"
    "path/filepath"
)

// Validate file paths
func SafeReadFile(basePath, filename string) ([]byte, error) {
    // Clean and join paths
    fullPath := filepath.Join(basePath, filename)

    // Ensure the file is within basePath
    absBase, err := filepath.Abs(basePath)
    if err != nil {
        return nil, err
    }

    absPath, err := filepath.Abs(fullPath)
    if err != nil {
        return nil, err
    }

    if !strings.HasPrefix(absPath, absBase) {
        return nil, errors.New("invalid file path")
    }

    // Limit file size
    info, err := os.Stat(absPath)
    if err != nil {
        return nil, err
    }
    if info.Size() > 10*1024*1024 { // 10MB limit
        return nil, errors.New("file too large")
    }

    return os.ReadFile(absPath)
}

// Create temporary files securely
func CreateTempFile() (*os.File, error) {
    // Use os.CreateTemp for secure temp files
    f, err := os.CreateTemp("", "prefix-*.tmp")
    if err != nil {
        return nil, err
    }

    // Set restrictive permissions
    err = f.Chmod(0600)
    if err != nil {
        f.Close()
        os.Remove(f.Name())
        return nil, err
    }

    return f, nil
}
```

## Race Conditions

### Thread-Safe Data Access

```go
import "sync"

// Thread-safe counter
type SafeCounter struct {
    mu    sync.Mutex
    count int
}

func (c *SafeCounter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}

func (c *SafeCounter) Value() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.count
}

// Thread-safe map
type SafeMap struct {
    mu   sync.RWMutex
    data map[string]interface{}
}

func (m *SafeMap) Set(key string, value interface{}) {
    m.mu.Lock()
    defer m.mu.Unlock()
    m.data[key] = value
}

func (m *SafeMap) Get(key string) (interface{}, bool) {
    m.mu.RLock()
    defer m.mu.RUnlock()
    val, ok := m.data[key]
    return val, ok
}
```

## Denial of Service Prevention

### Limit Resource Consumption

```go
// Limit request body size
func LimitRequestBody(h http.Handler, maxBytes int64) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        r.Body = http.MaxBytesReader(w, r.Body, maxBytes)
        h.ServeHTTP(w, r)
    })
}

// Limit concurrent operations
type Limiter struct {
    sem chan struct{}
}

func NewLimiter(max int) *Limiter {
    return &Limiter{
        sem: make(chan struct{}, max),
    }
}

func (l *Limiter) Acquire() {
    l.sem <- struct{}{}
}

func (l *Limiter) Release() {
    <-l.sem
}

func (l *Limiter) Do(fn func()) {
    l.Acquire()
    defer l.Release()
    fn()
}

// Implement rate limiting
import "golang.org/x/time/rate"

func RateLimitMiddleware(limiter *rate.Limiter) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            if !limiter.Allow() {
                http.Error(w, "rate limit exceeded", http.StatusTooManyRequests)
                return
            }
            next.ServeHTTP(w, r)
        })
    }
}
```

## Security Checklist

Before committing code, ensure:

- [ ] All user input is validated and sanitized
- [ ] Context with timeout is used for network operations
- [ ] Error messages don't expose sensitive information
- [ ] No hardcoded credentials or secrets
- [ ] Parameterized queries for all database operations
- [ ] File paths are validated and restricted
- [ ] Shared data structures are protected with mutexes
- [ ] Resource limits are implemented
- [ ] `govulncheck` passes without vulnerabilities
- [ ] Dependencies are up to date

## Additional Resources

- [Go Security Best Practices](https://github.com/OWASP/Go-SCP)
- [Go Vulnerability Database](https://pkg.go.dev/vuln)
- [OWASP Top Ten](https://owasp.org/www-project-top-ten/)

## Summary

Security is a critical aspect of Go development. Follow these practices:
1. Validate and sanitize all input
2. Use context for timeouts and cancellation
3. Don't expose sensitive information in errors
4. Use standard library crypto correctly
5. Prevent SQL injection with parameterized queries
6. Handle files and paths securely
7. Protect against race conditions
8. Implement resource limits
9. Keep dependencies updated
10. Run govulncheck regularly

Always run the validation script which includes security scanning with `govulncheck`.
