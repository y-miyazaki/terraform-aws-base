## Architecture (ARCH)

**ARCH-01 (SHOULD): Layer Separation**

Check: Are handler/usecase/repository separated and business/infrastructure layers separated?
Why: Mixed business logic and infrastructure layers make testing difficult, technology stack changes difficult
Fix: Apply Clean Architecture, separate handler/usecase/repository

**ARCH-02 (MUST): Dependency Injection**

Check: Are dependencies passed via constructor arguments as interfaces rather than accessed as global variables?
Why: Global variable dependencies and hardcoded dependencies prevent mocking, parallel testing
Fix: Accept dependencies as interface arguments in constructors; use wire/dig only when constructor graphs become complex

**ARCH-03 (SHOULD): Domain Logic Isolation**

Check: Is business logic free from infrastructure concerns (DB, HTTP, external APIs)?
Why: Scattered business logic mixed with infrastructure makes testing difficult and technology changes expensive
Fix: Keep domain logic in pure Go types and functions; access infrastructure through interfaces defined in the domain layer

**ARCH-04 (SHOULD): SOLID Principles**

Check: Are SRP/OCP/LSP/ISP/DIP applied, interfaces segregated, and abstractions used?
Why: Single responsibility violations and no dependency inversion expand change impact scope, make extension difficult
Fix: Apply SOLID principles, segregate interfaces, use abstractions

**ARCH-05 (SHOULD): Appropriate Package Structure**

Check: Are there no circular dependencies, standard layout compliance, and internal/ utilization?
Why: Circular dependencies and package bloat make builds difficult, understanding difficult
Fix: Control dependency direction, comply with standard layout, utilize internal/

**ARCH-06 (SHOULD): Unified Configuration Management**

Check: Are viper/envconfig used, config structs consolidated, and environment variables prioritized?
Why: Scattered config values and unseparated environment configs cause config omissions, cross-environment inconsistencies
Fix: Use viper/envconfig, consolidate config structs, prioritize environment variables

**ARCH-07 (SHOULD): Unified Log Management**

Check: Are zap/zerolog unified, structured logging used, and trace ID propagated?
Why: Mixed logging libraries and inconsistent formats make log analysis difficult, monitoring difficult
Fix: Unify on zap/zerolog, use structured logging, propagate trace IDs

**ARCH-08 (SHOULD): Unified Error Management**

Check: Are error packages consolidated, error code systems defined, and standardized?
Why: Inconsistent error handling policies and undefined error codes make operations difficult
Fix: Consolidate error packages, define error code system, standardize

**ARCH-09 (SHOULD): External Integration Abstraction**

Check: Are adapter patterns, interface definitions, and abstraction layers implemented?
Why: Direct external API calls and no abstraction layer cause vendor lock-in, difficult testing
Fix: Adapter pattern, define interfaces, implement abstraction layer

**ARCH-10 (SHOULD): Module Design**

Check: Are boundaries clear, loosely coupled, highly cohesive, and public APIs minimized?
Why: Unclear module boundaries and excessive cohesion/coupling cause large change impact, difficult scaling
Fix: Clarify boundaries, loose coupling and high cohesion, minimize public APIs
