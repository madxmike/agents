# Spec to properties

Convert a goal into a ledger. This phase is deliberately verbose and produces no production code.

## 1. Establish the boundary

Ask, or infer from the repository:

- Who observes the system? Client, operator, downstream service, auditor.
- What can each observer see? Response bodies, status codes, database rows, logs, metrics, traces, files.
- What must never happen? These become `forbid` properties and are usually the highest-value entries.
- What is explicitly out of scope? Record it under `non_goals`.
- What is the natural key or identity? Most persistence defects are identity defects.
- What happens when each dependency is unavailable? Failure behaviour is a property, not an afterthought.

If an answer is unavailable, record the assumption in the property's `assumes` field rather than inventing a requirement.

## 2. Write scenarios before properties

A scenario is a stimulus, a required response, a time bound, and an evidence point.

| When | Then | Within | Evidence |
|---|---|---|---|
| PUT a valid book | 200, canonical ISBN echoed | 500 ms | response, row |
| GET an unassigned ISBN | 404, code `not_found` | 500 ms | response |
| PUT the same body twice | identical response, one row | 1 s | response, `COUNT(*)` |
| restart the process | GET returns the record | 5 s | response |
| write on instance A, read on B | 200 | 1 s | both responses |
| stop the database | 503, no driver text; `/healthz` 200; `/readyz` 503 | 2 s | responses |

Prefer scenarios that distinguish a real implementation from one that only appears to work. Restarting the process and reading from a second instance are the two cheapest tests that separate a database-backed service from a process-local map.

## 3. Group scenarios into properties

One property per distinct guarantee. Name them `group.behaviour`:

- `isbn.canonical`
- `book.persisted`
- `write.idempotent`
- `write.no_duplicate_under_concurrency`
- `api.error_shape`
- `api.survives_db_outage`
- `ops.liveness_vs_readiness`

Do not merge properties because they share a test. Merging destroys attribution: a failure no longer identifies which guarantee broke.

## 4. Classify each property

For each, record `kind`, `scope`, `locus`, `polarity`.

- If the property is about code structure, naming, or comments, it is not in scope for the first pass. If it must be included, it is `derived`, needs multiple indicators, and needs a cheat corpus.
- If `locus` is not `code`, mark it and plan to report it rather than satisfy it.

## 5. Write the witness

The witness is the observation that proves the property false. Examples:

| Property | Witness |
|---|---|
| `book.persisted` | Process restarted; GET returns 404 for a book that previously returned 200. |
| `isbn.canonical` | Two rows whose ISBNs differ only by 10/13 form. |
| `write.idempotent` | Two rows after two identical requests. |
| `api.error_shape` | Response body contains a driver error string. |
| `ops.liveness_vs_readiness` | `/healthz` fails while the database is down. |

If you cannot write a witness, the property is not yet defined. Rewrite it.

## 6. Choose the check

Prefer, in order:

1. An existing command that already runs in CI.
2. A unit test on a pure function.
3. An integration test against the real dependency.
4. A static check or lint rule.
5. A metric with a recorded baseline.
6. Manual inspection, recorded as `assumed` with a reason.

Never record `tested` for a check that has not been executed.

## 7. Record evidence and assumptions

Set `evidence` to the weakest class that the planned check will actually establish. List every external premise in `assumes`.

Common assumptions that must be written down:

- the database enforces uniqueness under concurrency
- the provider deduplicates on our key
- the clock is monotonic enough for the lease
- the load balancer retries only idempotent methods
- the test double behaves like the production dependency

## 8. Check for conflicts

Two properties conflict when satisfying one necessarily violates the other. Typical pairs: size limits versus cohesion, caching versus freshness, strict validation versus forward compatibility.

Record the conflict. If one property has priority, state the order. If not, stop and ask.

## 9. Produce the artifacts

Write `.factory/ledger.yaml` and `.factory/scenarios.md`. Report the property count, the number of `assumed` entries, and any unresolved conflicts. Do not begin implementation in this phase.

## Planner boundary

The planner writes outcomes, not methods. The implementer chooses how.

**Include:**

- observable behavior, status codes, bodies, error codes
- domain rules and identity
- failure behavior and time bounds
- structural constraints stated as outcomes
- the evidence required and the acceptance check
- non-goals and unresolved conflicts

**Exclude:**

- file and package paths
- function and type signatures
- SQL, algorithms, and the order of internal steps
- test names or locations
- refactor sequences

**Test:** could a competent implementer satisfy this without seeing the original code? If the spec names a file, a function, a statement, or a refactor step, it is over-prescribed. Rewrite it as the observation that would prove the property false.

The property spec does not choose types. That is the next phase, `type-design.md`, which decides which invariants become unrepresentable and which stay on the escape list.
