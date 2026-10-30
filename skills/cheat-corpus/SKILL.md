---
name: cheat-corpus
description: Generate adversarial diffs that must be rejected, in order to test whether a property check actually catches implementations that satisfy the check without satisfying the property. Use when defining a derived or fuzzy property, hardening a CI gate, reviewing whether a test suite can be gamed, or verifying that a new check has teeth before relying on it.
disable-model-invocation: false
---

# Cheat corpus

Code can satisfy a check without satisfying the property. A derived property is a proxy, and every proxy has a bypass. The corpus is the test suite for the definition: a set of small, plausible diffs that the gate must reject.

This is not a test of the code. It is a test of the check.

## Procedure

1. Read the property's `statement`, `witness`, and `check`.
2. Enumerate bypasses: ways to make the check pass while the witness remains possible. Use `references/cheat-patterns.md` as a starting catalogue, then add bypasses specific to this property.
3. For each bypass, write the smallest patch a reviewer could plausibly accept.
4. Write the expectation file.
5. Apply the patch to a clean tree. Run the full gate, not only the property's command.
6. Confirm the intended check rejects it.
7. If the cheat is accepted, the definition or the check is too weak. Amend the property, keep the cheat, and repeat.
8. Commit the corpus alongside the property definition version.

## Layout

```
.factory/cheats/<property-id>/
  001-<name>.patch
  001-<name>.expect.md
```

`expect.md`:

```markdown
# empty-idempotency-key

Property: write.idempotent
Bypass: the retry loop passes an empty key, so every attempt is treated as a new request.
Must be rejected by: retry behavioural test
Expected verdict: reject
Notes: compiles, passes the arity check, and looks correct in review.
```

## Rules

1. One bypass per cheat. A cheat that exercises two is two cheats.
2. The patch must compile and must not break unrelated tests. A cheat that fails for the wrong reason proves nothing.
3. The patch must be plausible. If no reviewer could accept it, it is not a threat model.
4. Never delete a cheat because the fix was applied. The corpus is regression protection for the definition.
5. Version the corpus with the property definition. When the definition changes, re-run every cheat.
6. If a cheat cannot be written, record that explicitly. An untestable property is a finding, not a pass.

## Reporting

Report one line per cheat: name, verdict, and the check that caught it. If any cheat was accepted, report the amended definition and the new cheat count.

```
Cheats for isbn.canonical (4):
  001 strip-non-digits-only      rejected  (checksum table)
  002 accept-any-13-digits       rejected  (negative cases)
  003 store-isbn10-separately    rejected  (canonicalisation test)
  004 trust-client-checksum      rejected  (invalid-checksum response)
```
