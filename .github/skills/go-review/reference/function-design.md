### 5. Function Design (FUNC)

**FUNC-01: Appropriate Function Splitting**

Check: Are there no multiple responsibilities or mixed business/infrastructure layers in single functions?
Why: Mixed responsibilities make testing difficult, prevent reuse, increase maintenance cost
Fix: Apply single responsibility principle, separate layers, extract helper functions

**FUNC-02: Appropriate Argument Design**

Check: Are there no excessive positional arguments or bool argument overuse, and are options handled appropriately?
Why: Too many arguments and bool overuse cause caller misuse, difficult extension
Fix: Use Functional Options Pattern, convert to struct arguments

**FUNC-03: Return Value Design**

Check: Are named returns minimized, error placed last, and multiple returns appropriate?
Why: Named return overuse and inconsistent error position cause error handling omissions, API inconsistency
Fix: Minimize named returns, place error last, keep return values to 2-3

**FUNC-04: Recommend Pure Functions**

Check: Are there no global variable references, mixed side effects, or non-deterministic behavior?
Why: Mixed side effects make testing difficult, prevent parallel execution, unpredictable
Fix: Accept all inputs via arguments, separate side effects, dependency injection

**FUNC-05: Appropriate Receiver Design**

Check: Are there no mixed pointer/value receivers or large value receivers?
Why: Mixed receivers cause copy costs, changes not reflected, reduced readability
Fix: Pointer receiver principle, unify receiver name to 1-2 characters

**FUNC-06: Method Set Design**

Check: Are there no unrelated methods mixed, God Object formation, or unclear responsibility scope?
Why: Mixed methods make maintenance difficult, bloat test scope, increase understanding cost
Fix: Highly cohesive method sets, split types, segregate interfaces

**FUNC-07: Appropriate Initialization Functions**

Check: Do New functions implement error handling and validation?
Why: Missing error handling creates invalid state objects, initialization failure undetectable
Fix: Return error from NewXxx(), implement validation, separate Must functions

**FUNC-08: Leverage Higher-Order Functions**

Check: Are callbacks and function pointers appropriately utilized?
Why: Unused callbacks reduce extensibility, duplicate code, lack flexibility
Fix: Apply strategy pattern, Functional Options, leverage callbacks

**FUNC-09: Appropriate Generics Usage**

Check: Are there no interface{} overuse or unnecessary generics?
Why: interface{} overuse lacks type safety, excessive generics increase complexity
Fix: Appropriate type parameter usage, define constraints, avoid excessive abstraction

**FUNC-10: Comprehensive Function Documentation**

Check: Do all public functions have godoc with argument and return value descriptions?
Why: Missing godoc makes API understanding difficult, increases misuse, maintenance burden
Fix: godoc for all public functions, specify arguments, return values, error conditions
