---
name: evidence-audit
description: Audit a repository or diff for fake or overstated verification. Classify each property's actual evidence, detect tests that cannot fail, doubles that define the outcome, stale coverage, and unverifiable derived properties. Use before declaring work complete, when reviewing a pull request, or when asked whether a test suite can be trusted.
disable-model-invocation: false
---

# Evidence audit

Tests are not evidence by existing. They are evidence when they would fail if the property were violated. This skill determines, per property, what the suite actually establishes.

## Evidence classes

| class | meaning |
|---|---|
| `tested` | executed against inputs. A failure is proof; a pass is a sample. |
| `bounded-proved` | exhaustive over a stated finite model or bound. |
| `proved` | holds for all executions of a stated model. |
| `assumed` | depends on an external premise that was not demonstrated. |
| `none` | no check, or no check that can fail. |

Always downgrade rather than argue. A property is as strong as its weakest assumption.

## Procedure

For each property in the ledger:

1. **Locate the artifact.** Find the test, check, or metric. If there is none, record `none`.
2. **Run it.** A check that does not run in CI is `none` for gating purposes.
3. **Deletion test.** Stub or delete the production code the property describes. Does the check fail? If it still passes, the check is not evidence.
4. **Mutation spot-check.** Invert a condition, change a constant, or remove an error return. Does any check fail? Do this two or three times per property.
5. **Dependency test.** If the check uses a double, ask whether the double enforces the constraint being claimed. An in-memory store that ignores duplicate keys cannot verify uniqueness.
6. **Assertion direction.** Read the assertion. Does it state the required behaviour, or restate the current behaviour?
7. **Negative case.** For every `require` property, is there an input that must be rejected? For every `forbid` property, is there a witness test?
8. **Re-execution.** Is the check wired into the command that runs on every change? Is failure fatal, or advisory?
9. **Staleness.** Has the covered code path changed since the check was written? Use coverage or a targeted mutation.
10. **History dependence.** If an indicator reads git history, deployment metrics, or review outcomes, it is not a function of the tree. It cannot gate a diff and must not be used as a search gradient.
11. **Waivers.** List them. Check expiry. An expired waiver is a failed property.
12. **Assumptions.** Read `assumes`. For each, ask what test validates it. Unvalidated assumptions keep the property at `assumed` regardless of the test result.

## Red flags

- A test asserts a value produced by the same function it is testing.
- A test passes with the implementation deleted.
- The only test for a persistence property uses an in-memory store.
- A test sets an environment flag that the production code reads.
- Assertions were removed in the same diff that added behaviour.
- Coverage rose while the diff only added mocks.
- An integration test spins up the dependency but the assertion reads from the mock.
- A `proved` claim does not name a model.
- A `forbid` property has no negative test.
- A check exists but runs only on a manual command.
- A waiver has no expiry.
- A property's check was written before the property's statement changed.

## Output

Produce a table and a verdict.

| Property | Claimed | Verified | Gap | Action |
|---|---|---|---|---|
| `book.persisted` | tested | none | only the in-memory store is exercised | add restart test against real engine |
| `isbn.canonical` | tested | tested | none | keep |

Then:

- **Trustworthy properties:** count and list.
- **Overstated properties:** each with the claim, the actual class, and the specific missing check.
- **Unfalsifiable properties:** properties whose witness cannot be observed by any current check.
- **Blocking assumptions:** assumptions that, if false, invalidate a claimed class.

## Rules

1. Do not accept "the tests pass" as an answer. Ask which test would fail if the property were false.
2. A check that has never failed is suspect until a deliberate fault is introduced.
3. Do not fix the tests during an audit unless the user asks. Report first; the audit's output is the finding.
4. If the ledger is absent, reconstruct the claimed properties from the tests and say so explicitly. Do not invent requirements.
