---
name: formal-escalation
description: Decide and implement stronger evidence when testing cannot settle a property. Covers exhaustive interleaving enumeration, protocol model checking, bounded model checking, contracts, and differential or metamorphic testing, with the assumptions each one leaves behind. Use for concurrency, protocol invariants, money arithmetic, memory safety, authorisation, or any property whose input space is unbounded.
disable-model-invocation: false
---

# Formal escalation

Testing gives samples. Some properties require exhaustion over a model or a proof. This skill selects the cheapest technique that can actually settle the property, and records what remains assumed.

## When to escalate

- Concurrency: duplicate writes, lost updates, double spend.
- Protocol invariants across clients, restarts, or crashes.
- Arithmetic over money, dates, or identifiers where rounding matters.
- Memory safety or undefined behaviour.
- Authorisation, where the requirement quantifies over all routes and all states.
- Any `forbid` property with a high consequence of failure.

## Technique selection

| Property shape | Technique | Bound or model to state |
|---|---|---|
| Finite interleavings at one boundary | Exhaustive enumeration over a small model | thread count, step count |
| Protocol invariant, many clients, crash/restart | Model checking: TLA+, Apalache, SPIN | number of clients, failure model |
| Structural or relational invariant | Alloy | scope of each signature |
| Pure arithmetic | Property-based tests, then contracts (Dafny, F*, Verus) | generator domain |
| Memory safety | Bounded model checking: CBMC, Kani, JBMC | input bounds, loop unwinding |
| Unbounded inputs | Fuzzing plus differential testing | corpus and duration; a pass is a sample |
| Authorisation | Endpoint enumeration plus information-flow analysis | route list, role matrix |

Language constraint: Go has no mature deductive verifier. For Go, escalation means exhaustive enumeration at a boundary, a TLA+ or Alloy model, fuzzing, differential testing, and the race detector. Do not recommend a contract verifier that does not exist for the language.

## Procedure

1. State the property, the model boundary, and what the model deliberately excludes.
2. Write the smallest model that can express a violation. If the model cannot fail, it proves nothing.
3. Run a **negative control**: introduce a known bug and confirm the checker reports it. If the checker passes the broken version, it is not checking anything.
4. State the assumptions: atomicity of the store, failure model, clock behaviour, number of actors.
5. Run the checker over the stated bound or scope.
6. Record the artifact path, the bound, and the assumptions in the ledger.
7. Add a conformance test that bridges the model and the implementation. Without it, the result applies only to the model.
8. Set `evidence` to `bounded-proved` or `proved`, and name the model in `assumes`.

## Example: interleaving enumeration

The cheapest escalation for a single-boundary race. The model is the program's steps, not the implementation.

```go
// Two threads, steps [check, insert]. Enumerate all orderings; assert the
// invariant over each terminal state. atomicInsert models a unique constraint.
func explore(atomicInsert bool) int {
	violations := 0
	for _, order := range interleavings(2, 2) { // 20 orderings
		var st state
		for _, step := range order {
			st = st.apply(step, atomicInsert)
		}
		if st.charges > 1 {
			violations++
		}
	}
	return violations
}
```

The test asserts `violations == 0` for the production implementation's semantics and `violations > 0` for the naive check-then-insert. The second assertion is the negative control.

## Example: protocol invariant

```tla
---- MODULE Orders ----
EXTENDS Naturals, TLC
CONSTANT Keys
VARIABLE store

Init == store = [k \in Keys |-> 0]

Place(k) ==
    /\ store[k] = 0
    /\ store' = [store EXCEPT ![k] = 1]

Next == \E k \in Keys : Place(k)
Spec == Init /\ [][Next]_store

AtMostOneCharge == \A k \in Keys : store[k] <= 1
====
```

`store[k] = 0` is the premise that the database enforces uniqueness atomically. The model proves the invariant relative to that premise; it does not prove the database does it.

## Rules

1. Never claim `proved` without naming the model and its premises.
2. Every proof is conditional. Put the conditions in `assumes`; they are the remaining risk.
3. A bounded result must state its bound, and the bound must be justified by the failure mode, not by convenience.
4. A model that cannot express a violation is worthless. Run the negative control first.
5. The model-code gap is real. Close it with a conformance test or state it as an assumption.
6. Do not escalate a property that a unit test can settle. Escalation is expensive and should be reserved for properties where a sample is insufficient.
