# Ordering (ORD)

**ORD-01 (MUST): Alphabetize argument keys inside resource/module/data/local blocks**

Check: Are argument keys inside each resource, module, data, and local block sorted alphabetically (A-Z)?
Why: Inconsistent ordering adds diff noise and makes change detection harder
Fix: Sort argument keys alphabetically within each block
Note: The companion validation's `--check-order` step (when its helper is available) checks only top-level arguments of `resource`, `data`, and `module` blocks. When its output is supplied, take the status of those blocks from it and cite it; still evaluate `locals` blocks and nested blocks from source, because the step does not check them.
