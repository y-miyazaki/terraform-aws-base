### 10. Architecture (ARCH)

**ARCH-01: Layer Separation**

Check: Are handler/usecase/repository separated and business/infrastructure layers separated?
Why: Mixed business logic and infrastructure layers make testing difficult, technology stack changes difficult
Fix: Apply Clean Architecture, separate handler/usecase/repository

**ARCH-02: Dependency Injection**

Check: Are constructor injection, wire/dig utilization, and interface dependencies present?
Why: Global variable dependencies and hardcoded dependencies prevent mocking, parallel testing
Fix: Constructor injection, leverage wire/dig, depend on interfaces

**ARCH-03: Domain-Driven Design**

Check: Are aggregate roots defined, Value Objects utilized, and Repositories abstracted?
Why: Anemic domain models and scattered business logic make consistency guarantees difficult
Fix: Define aggregate roots, utilize Value Objects, abstract Repositories

**ARCH-04: SOLID Principles**

Check: Are SRP/OCP/LSP/ISP/DIP applied, interfaces segregated, and abstractions used?
Why: Single responsibility violations and no dependency inversion expand change impact scope, make extension difficult
Fix: Apply SOLID principles, segregate interfaces, use abstractions

**ARCH-05: Appropriate Package Structure**

Check: Are there no circular dependencies, standard layout compliance, and internal/ utilization?
Why: Circular dependencies and package bloat make builds difficult, understanding difficult
Fix: Control dependency direction, comply with standard layout, utilize internal/

**ARCH-06: Unified Configuration Management**

Check: Are viper/envconfig used, config structs consolidated, and environment variables prioritized?
Why: Scattered config values and unseparated environment configs cause config omissions, cross-environment inconsistencies
Fix: Use viper/envconfig, consolidate config structs, prioritize environment variables

**ARCH-07: Unified Log Management**

Check: Are zap/zerolog unified, structured logging used, and trace ID propagated?
Why: Mixed logging libraries and inconsistent formats make log analysis difficult, monitoring difficult
Fix: Unify on zap/zerolog, use structured logging, propagate trace IDs

**ARCH-08: Unified Error Management**

Check: Are error packages consolidated, error code systems defined, and standardized?
Why: Inconsistent error handling policies and undefined error codes make operations difficult
Fix: Consolidate error packages, define error code system, standardize

**ARCH-09: External Integration Abstraction**

Check: Are adapter patterns, interface definitions, and abstraction layers implemented?
Why: Direct external API calls and no abstraction layer cause vendor lock-in, difficult testing
Fix: Adapter pattern, define interfaces, implement abstraction layer

**ARCH-10: Module Design**

Check: Are boundaries clear, loosely coupled, highly cohesive, and public APIs minimized?
Why: Unclear module boundaries and excessive cohesion/coupling cause large change impact, difficult scaling
Fix: Clarify boundaries, loose coupling and high cohesion, minimize public APIs
