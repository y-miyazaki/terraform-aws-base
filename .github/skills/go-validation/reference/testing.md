# Go Validation - Testing Best Practices

## Contents

- [Go Validation - Testing Best Practices](#go-validation---testing-best-practices)
  - [Contents](#contents)
  - [Overview](#overview)
  - [Test Structure](#test-structure)
    - [Basic Test Structure](#basic-test-structure)
  - [Table-Driven Tests](#table-driven-tests)
    - [Basic Table-Driven Pattern](#basic-table-driven-pattern)
    - [Advanced Table-Driven Pattern with Error Cases](#advanced-table-driven-pattern-with-error-cases)
  - [Test Helpers](#test-helpers)
    - [Using t.Helper()](#using-thelper)
    - [Setup and Cleanup](#setup-and-cleanup)
  - [Mocking and Test Doubles](#mocking-and-test-doubles)
    - [Interface-Based Mocking](#interface-based-mocking)
    - [testify/mock Package](#testifymock-package)
  - [Coverage Strategies](#coverage-strategies)
    - [Improving Coverage](#improving-coverage)
    - [Coverage Analysis](#coverage-analysis)
  - [Testing Concurrent Code](#testing-concurrent-code)
    - [Testing with Race Detector](#testing-with-race-detector)
    - [Testing Channels](#testing-channels)
    - [Testing Timeouts](#testing-timeouts)
  - [Benchmarking](#benchmarking)
    - [Basic Benchmarks](#basic-benchmarks)
    - [Table-Driven Benchmarks](#table-driven-benchmarks)
  - [Test Organization](#test-organization)
    - [File Naming](#file-naming)
    - [Test Package Naming](#test-package-naming)
  - [Common Patterns](#common-patterns)
    - [Golden Files](#golden-files)
    - [Testing HTTP Handlers](#testing-http-handlers)
  - [Summary](#summary)

## Overview

This guide provides patterns and best practices for writing effective Go tests that meet validation requirements.

## Test Structure

### Basic Test Structure

```go
package mypackage_test

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

// Setup and teardown
func setup(t *testing.T) *TestContext {
    t.Helper()
    // Setup code
    ctx := &TestContext{}

    t.Cleanup(func() {
        // Cleanup code
        ctx.Close()
    })

    return ctx
}

// Test functions follow AAA pattern: Arrange-Act-Assert
func TestMyFunction(t *testing.T) {
    // Arrange - Set up test data and dependencies
    input := "test input"
    expected := "expected output"

    // Act - Execute the function being tested
    result := MyFunction(input)

    // Assert - Verify the results
    assert.Equal(t, expected, result)
}
```

## Table-Driven Tests

### Basic Table-Driven Pattern

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -1, -2, -3},
        {"zero", 0, 0, 0},
        {"mixed", -5, 10, 5},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            assert.Equal(t, tt.expected, result)
        })
    }
}
```

### Advanced Table-Driven Pattern with Error Cases

```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name      string
        email     string
        wantErr   bool
        errString string
    }{
        {
            name:    "valid email",
            email:   "user@example.com",
            wantErr: false,
        },
        {
            name:      "missing @",
            email:     "userexample.com",
            wantErr:   true,
            errString: "invalid email format",
        },
        {
            name:      "empty email",
            email:     "",
            wantErr:   true,
            errString: "email cannot be empty",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateEmail(tt.email)

            if tt.wantErr {
                require.Error(t, err)
                assert.Contains(t, err.Error(), tt.errString)
            } else {
                require.NoError(t, err)
            }
        })
    }
}
```

## Test Helpers

### Using t.Helper()

```go
// Helper function for common assertions
func assertUserValid(t *testing.T, user *User) {
    t.Helper() // Mark as helper for better error messages

    require.NotNil(t, user)
    assert.NotEmpty(t, user.ID)
    assert.NotEmpty(t, user.Name)
}

// Helper for test setup
func createTestUser(t *testing.T, name string) *User {
    t.Helper()

    user := &User{
        ID:   generateID(),
        Name: name,
    }

    t.Cleanup(func() {
        cleanupUser(user)
    })

    return user
}
```

### Setup and Cleanup

```go
func TestDatabaseOperations(t *testing.T) {
    // Setup
    db := setupTestDB(t)

    // Test code
    user := &User{Name: "Test"}
    err := db.SaveUser(user)
    require.NoError(t, err)

    // Cleanup happens automatically via t.Cleanup
}

func setupTestDB(t *testing.T) *Database {
    t.Helper()

    db, err := OpenDatabase(":memory:")
    require.NoError(t, err)

    // Register cleanup
    t.Cleanup(func() {
        _ = db.Close()
    })

    return db
}
```

## Mocking and Test Doubles

### Interface-Based Mocking

```go
// Production interface
type DataStore interface {
    Get(key string) (string, error)
    Set(key, value string) error
}

// Mock implementation for testing
type MockDataStore struct {
    GetFunc func(key string) (string, error)
    SetFunc func(key, value string) error

    getCalls []string
    setCalls [][2]string
}

func (m *MockDataStore) Get(key string) (string, error) {
    m.getCalls = append(m.getCalls, key)
    if m.GetFunc != nil {
        return m.GetFunc(key)
    }
    return "", nil
}

func (m *MockDataStore) Set(key, value string) error {
    m.setCalls = append(m.setCalls, [2]string{key, value})
    if m.SetFunc != nil {
        return m.SetFunc(key, value)
    }
    return nil
}

// Usage in test
func TestMyService(t *testing.T) {
    mock := &MockDataStore{
        GetFunc: func(key string) (string, error) {
            if key == "test" {
                return "value", nil
            }
            return "", errors.New("not found")
        },
    }

    service := NewService(mock)
    result, err := service.Process("test")

    require.NoError(t, err)
    assert.Equal(t, "processed value", result)
    assert.Len(t, mock.getCalls, 1)
}
```

### testify/mock Package

```go
import (
    "github.com/stretchr/testify/mock"
)

type MockDataStore struct {
    mock.Mock
}

func (m *MockDataStore) Get(key string) (string, error) {
    args := m.Called(key)
    return args.String(0), args.Error(1)
}

func (m *MockDataStore) Set(key, value string) error {
    args := m.Called(key, value)
    return args.Error(0)
}

// Usage in test
func TestWithMock(t *testing.T) {
    mockStore := new(MockDataStore)

    // Set expectations
    mockStore.On("Get", "key1").Return("value1", nil)
    mockStore.On("Set", "key2", "value2").Return(nil)

    // Test code
    service := NewService(mockStore)
    err := service.DoSomething()

    require.NoError(t, err)
    mockStore.AssertExpectations(t)
}
```

## Coverage Strategies

### Improving Coverage

1. **Test all public APIs**:
```go
// Ensure all exported functions have tests
func TestPublicAPI(t *testing.T) {
    tests := []struct {
        name string
        test func(t *testing.T)
    }{
        {"NewClient", testNewClient},
        {"Client.Connect", testClientConnect},
        {"Client.Send", testClientSend},
        {"Client.Close", testClientClose},
    }

    for _, tt := range tests {
        t.Run(tt.name, tt.test)
    }
}
```

2. **Test error paths**:
```go
func TestErrorHandling(t *testing.T) {
    tests := []struct {
        name      string
        input     string
        wantErr   bool
        setupMock func(*MockDataStore)
    }{
        {
            name:    "success",
            input:   "valid",
            wantErr: false,
            setupMock: func(m *MockDataStore) {
                m.On("Get", mock.Anything).Return("value", nil)
            },
        },
        {
            name:    "database error",
            input:   "test",
            wantErr: true,
            setupMock: func(m *MockDataStore) {
                m.On("Get", mock.Anything).Return("", errors.New("db error"))
            },
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mock := new(MockDataStore)
            tt.setupMock(mock)

            _, err := Process(mock, tt.input)
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
            }
        })
    }
}
```

3. **Test edge cases**:
```go
func TestEdgeCases(t *testing.T) {
    tests := []struct {
        name  string
        input []int
        want  int
    }{
        {"empty slice", []int{}, 0},
        {"single element", []int{5}, 5},
        {"negative numbers", []int{-1, -5, -3}, -1},
        {"mixed", []int{-5, 0, 10, -3}, 10},
        {"all zeros", []int{0, 0, 0}, 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := FindMax(tt.input)
            assert.Equal(t, tt.want, result)
        })
    }
}
```

### Coverage Analysis

```bash
# Generate coverage profile
go test -coverprofile=/workspace/tmp/coverage.out ./...

# View coverage by function
go tool cover -func=/workspace/tmp/coverage.out

# View coverage in browser
go tool cover -html=/workspace/tmp/coverage.out -o /workspace/tmp/coverage.html

# Check coverage threshold
go test -coverprofile=/workspace/tmp/coverage.out ./...
go tool cover -func=/workspace/tmp/coverage.out | grep total | awk '{print $3}'
```

## Testing Concurrent Code

### Testing with Race Detector

```go
func TestConcurrentAccess(t *testing.T) {
    counter := &SafeCounter{}
    const numGoroutines = 100
    const numIncrements = 1000

    var wg sync.WaitGroup
    wg.Add(numGoroutines)

    for i := 0; i < numGoroutines; i++ {
        go func() {
            defer wg.Done()
            for j := 0; j < numIncrements; j++ {
                counter.Increment()
            }
        }()
    }

    wg.Wait()

    expected := numGoroutines * numIncrements
    assert.Equal(t, expected, counter.Value())
}

// Run with: go test -race
```

### Testing Channels

```go
func TestChannelCommunication(t *testing.T) {
    results := make(chan int, 10)
    done := make(chan bool)

    go func() {
        for i := 0; i < 10; i++ {
            results <- i
        }
        close(results)
        done <- true
    }()

    var received []int
    for val := range results {
        received = append(received, val)
    }

    <-done
    assert.Len(t, received, 10)
}
```

### Testing Timeouts

```go
func TestWithTimeout(t *testing.T) {
    ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
    defer cancel()

    result := make(chan string, 1)
    go func() {
        time.Sleep(50 * time.Millisecond)
        result <- "success"
    }()

    select {
    case res := <-result:
        assert.Equal(t, "success", res)
    case <-ctx.Done():
        t.Fatal("test timed out")
    }
}
```

## Benchmarking

### Basic Benchmarks

```go
func BenchmarkMyFunction(b *testing.B) {
    input := generateTestData()

    b.ResetTimer() // Reset timer after setup

    for i := 0; i < b.N; i++ {
        MyFunction(input)
    }
}

// Run with: go test -bench=. -benchmem
```

### Table-Driven Benchmarks

```go
func BenchmarkStringOperations(b *testing.B) {
    benchmarks := []struct {
        name  string
        input []string
    }{
        {"small", generateStrings(10)},
        {"medium", generateStrings(100)},
        {"large", generateStrings(1000)},
    }

    for _, bm := range benchmarks {
        b.Run(bm.name, func(b *testing.B) {
            for i := 0; i < b.N; i++ {
                ConcatenateStrings(bm.input)
            }
        })
    }
}
```

## Test Organization

### File Naming

```
mypackage/
├── user.go
├── user_test.go       # Tests for user.go
├── auth.go
├── auth_test.go       # Tests for auth.go
└── testdata/          # Test fixtures
    └── sample.json
```

### Test Package Naming

```go
// Internal testing (access to private members)
package mypackage

import "testing"

func TestInternalFunction(t *testing.T) {
    // Can access private functions
}

// External testing (public API only)
package mypackage_test

import (
    "testing"
    "myapp/mypackage"
)

func TestPublicAPI(t *testing.T) {
    // Can only access exported functions
}
```

## Common Patterns

### Golden Files

```go
func TestOutputFormat(t *testing.T) {
    result := GenerateReport(testData)

    goldenFile := "testdata/report.golden"

    if *update {
        // Update golden file
        err := os.WriteFile(goldenFile, []byte(result), 0644)
        require.NoError(t, err)
    }

    expected, err := os.ReadFile(goldenFile)
    require.NoError(t, err)

    assert.Equal(t, string(expected), result)
}

var update = flag.Bool("update", false, "update golden files")
```

### Testing HTTP Handlers

```go
func TestHTTPHandler(t *testing.T) {
    req := httptest.NewRequest("GET", "/api/users", nil)
    rec := httptest.NewRecorder()

    handler := NewUserHandler(mockStore)
    handler.ServeHTTP(rec, req)

    assert.Equal(t, http.StatusOK, rec.Code)

    var users []User
    err := json.Unmarshal(rec.Body.Bytes(), &users)
    require.NoError(t, err)
    assert.NotEmpty(t, users)
}
```

## Summary

Effective Go testing requires:
- Clear test structure (AAA pattern)
- Table-driven tests for multiple scenarios
- Proper use of helpers and cleanup
- Strategic mocking for dependencies
- Comprehensive coverage of edge cases and error paths
- Race detection for concurrent code
- Benchmarking for performance-critical code

Follow these patterns to achieve and maintain ≥ 80% test coverage.
