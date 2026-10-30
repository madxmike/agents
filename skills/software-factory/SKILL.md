---
name: software-factory
description: Turn a product or engineering goal into a ledger of externally observable properties, order the work into small independently verifiable slices, and run an execute-verify loop until each property is satisfied. Use when starting a system from zero code, reframing an existing repository around observable behavior, planning a multi-step change where every diff must be attributable, or when the user asks for a property ledger, slice plan, or reconciliation loop.
disable-model-invocation: false
---

# Software Factory

Produce software by satisfying named, checkable properties with small attributed diffs. The unit of work is a property, not a feature. A diff that closes five properties and then fails tells you nothing; a diff that closes one tells you exactly what broke.

## Hard rules

1. No production code before `.factory/ledger.yaml` exists. If the user pushes to start coding, write the ledger first and treat it as the plan.
2. One slice closes exactly one property. If a slice closes two, split it or record the coupling explicitly.
3. Every slice has a verification command. If no command can be written, the property is `assumed` and must be recorded as such, not quietly skipped.
4. Re-verify after every slice. Never plan the whole sequence and execute it blind.
5. Prefer the smallest diff that satisfies the property. If the smallest diff is wrong for design reasons, record the tradeoff in the slice.
6. Do not fix unrelated defects. Record them as new ledger entries instead.
7. State the evidence class honestly. Never write `tested` for something that was not executed, and never write `proved` without naming the model and its premises.
8. Commit per slice, with the property id in the message.
9. A judged result never promotes a property above `tested` on its own.

## Artifacts

Create at the repository root:

```
.factory/
  ledger.yaml          # properties, scope decisions, non-goals
  scenarios.md         # stimuli, required responses, evidence points
  slices.md            # ordered work, one property per slice
  evidence.md          # per-property evidence, artifacts, assumptions
  cheats/              # adversarial diffs that must be rejected
  spec/                # optional: TLA+, Alloy, contracts
```

Templates: `templates/ledger.yaml`, `templates/scenarios.md`.

## Procedure

### Phase 1: Establish the ledger

Read `references/spec-to-properties.md`. Produce `.factory/ledger.yaml` and `.factory/scenarios.md`.

Do not proceed until every property has a statement, a witness, a check (or `assumed`), and an evidence class. Ask the user to confirm any property that is `assumed` or that conflicts with another property.

### Phase 2: Plan the slices

Read `references/slice-plan.md`. Produce `.factory/slices.md`.

The plan must contain a first slice that adds the verification harness and no behavior, and must not schedule a property whose check depends on a property that is not yet satisfied.

### Phase 3: Execute and verify

Read `references/execute-slice.md`. Execute one slice, verify it, update the ledger, commit.

For text properties with no deterministic check, run judged checks and record them as `judged` evidence (`references/judged-checks.md`). Do not promote a property on judged evidence alone.

Repeat until no unmet properties remain or the user stops the loop. After each slice, recompute obligations from the ledger rather than assuming the plan still holds.

### Phase 4: Audit

Invoke the `evidence-audit` skill before declaring completion, and whenever the user asks whether the suite is trustworthy.

### Phase 5: Escalate evidence where required

Invoke the `formal-escalation` skill for properties that testing cannot settle: concurrency, protocol invariants, arithmetic over money, and unbounded input spaces.

### Always

Invoke the `cheat-corpus` skill for every derived property, and for every integration property that a plausible wrong implementation could satisfy by accident.

## What to refuse

- An obligation whose `locus` is not `code` (for example a latency target that requires a database index or cache policy). Report it as out of scope instead of emitting a code diff that pretends to address it.
- A property with no witness. Ask what observation would prove it false.
- A request to weaken a check so a diff passes. If the check is wrong, change the ledger explicitly and explain why.
- A derived property with a single indicator. One indicator is a proxy and will be satisfied without the construct.

## Reporting

After each slice, report in this form:

```
Slice: S03
Property: isbn.canonical
Diff: internal/isbn/isbn.go (+61/-0), isbn_test.go (+44/-0)
Verification: go test ./internal/isbn/... (pass)
Frame: go test ./... (pass)
Cheats applied: 2 (both rejected)
Evidence: tested (table + fuzz)
Commit: <sha>
Next obligation: book.persisted (needs real Postgres)
```

Report failures in the same form, with the failing command and the output. Do not summarise a failure as "tests failed."
