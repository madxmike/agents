# Execute one slice

## Procedure

1. Read the ledger entry and the slice definition. Restate the property and the witness in one sentence each.
2. Read the smallest relevant surface. Do not read the whole repository.
3. Write the minimal diff. Introduce no abstraction that is not used at least twice. Follow the project's existing conventions.
4. Run the slice's verification command.
5. Run the frame check: the full existing suite.
6. Apply the cheat corpus for the touched property, if one exists.
7. Run judged checks for text properties that have no deterministic check, and write the JSON artifact. See `judged-checks.md`.
8. Update `.factory/evidence.md` and the ledger's `evidence` field.
9. Commit with the property id.

## Failure protocol

1. Re-run once. Distinguish a flake from a failure before changing anything.
2. If deterministic, diagnose once. Identify whether the cause is in the slice's `diff_scope`.
3. If the cause is inside the scope, fix it and re-run. One repair attempt.
4. If the cause is outside the scope, revert the slice. Record a new ledger entry or a blocker. Do not stack unrelated fixes.
5. Never weaken the check to make the diff pass. If the check itself is wrong, change the ledger explicitly, state why, and get agreement.

A slice that requires more than one repair attempt should be reverted and re-planned. Stacked fixes destroy attribution.

## Frame check

Run the full suite, not only the slice's command. If an existing property breaks:

- the slice is too large, or
- an earlier property was recorded as satisfied without adequate evidence.

Either way, revert and re-plan. Do not delete or weaken the earlier check.

## Cheat check

For each cheat in `.factory/cheats/<property-id>/`:

1. Apply the patch to a clean tree.
2. Run the gate.
3. Confirm the cheat is rejected by the intended check.
4. Revert the patch.

If a cheat is accepted, the property definition or the check is too weak. Amend the property, not the cheat. Keep the cheat in the corpus.

## Ledger update

Set `evidence` to the class actually demonstrated. Add the artifact path:

```yaml
evidence: tested
assumes:
  - name: postgres_enforces_unique_index_under_concurrency
    validated_by: integration test against the production engine
```

If an assumption was not validated, it stays `assumed`. Do not promote an evidence class because the diff looks correct.

A judged result never promotes a property above `tested` on its own. If the only check for a property is judged, record `judged` and state what a deterministic check would require.

## Commit format

```
slice(S03): isbn.canonical — reject invalid checksums

Property: isbn.canonical
Evidence: tested (fixed table, fuzz round-trip)
Frame: go test ./... pass
```

One slice per commit. If a commit contains two properties, split it.

## Reporting

Report the slice, the diff size, the verification output, the frame result, the cheats applied, the resulting evidence class, and the next obligation. State failures with the command and output, not a summary.

## The executor chooses the method

Read the property and the contract. Choose the packages, signatures, and tests. If the plan prescribes code, stop and return to planning; do not implement a spec that has already decided the implementation.

Read `.factory/types.md` first. Construct values through the designed constructors. Do not add a conversion that bypasses an opaque type, and do not widen a parameter back to a primitive string or int to make a call compile. If a type is missing, return to type design rather than working around it.
