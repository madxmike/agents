# Cheat patterns

A catalogue of implementations that satisfy a check without satisfying the property. Adapt these to the language and property at hand; the list is not exhaustive.

## Structural and metric

**No-op reference.** A line that touches a value so a structural metric improves without any behavioural change.

```go
func (o *Order) SendReceipt() error {
	_ = o.ID // makes the mail path "share" order data
	return smtp(o.mailHost, o.ID)
}
```

Attacks: cohesion, coupling, fan-in, any graph-shaped indicator.

**Metric relocation.** Move complexity into a helper so the per-function metric improves while the total is unchanged. Complexity moves, branches do not disappear.

Attacks: cyclomatic complexity, function length, nesting depth.

**Wrapper inflation.** Add trivial wrappers to increase an implementation count or decrease an average.

Attacks: abstraction-has-consumers, average-size metrics.

## Persistence

**Fake persistence.** The handler writes to an in-process map. The SQL code exists but is never called. Every unit test passes.

Attacks: any property claimed to be about storage. Caught only by restart and multi-instance tests.

**Deferred side effect.** Return success before the write commits. The happy path passes; a crash between response and commit loses the record.

Attacks: at-most-once and durability properties.

**Process-local cache.** Read your own writes from memory, so a second instance does not see them.

Attacks: shared-state and multi-instance properties.

## Verification

**Test-only branch.** Detect the test environment and behave differently.

```go
if os.Getenv("TESTING") == "1" { return nil }
```

Attacks: every property whose check runs in a test harness. Mitigate by running at least one check against the real artifact.

**Self-fulfilling double.** The test double implements the property, so the test measures the double.

Attacks: integration properties. A mock that enforces uniqueness proves the mock enforces uniqueness.

**Arity-only fan-out.** Update every call site to compile, passing a zero value.

```go
Place(ctx, order, "") // retry loop
```

Attacks: properties whose guarantee depends on the argument's meaning.

**Assertion weakening.** Loosen or delete assertions so the suite passes.

Attacks: every property. Detect by comparing the test diff to the production diff.

**Tautological assertion.** Assert the code's output against the code's output.

```go
want, _ := Canonical(in)
got, _ := Canonical(in)
if got != want { ... } // never fails
```

Attacks: every property.

**Stale evidence.** The check still exists but no longer covers the changed path: the function was renamed, the test calls a different entry point, coverage silently dropped.

Attacks: every property. Detect by mutation spot-checks after changes.

## Failure and error surface

**Error leak.** Return the driver error string to the client.

```go
http.Error(w, err.Error(), 500)
```

Attacks: error-shape and information-disclosure properties.

**Swallowed error.** Discard the error and return success.

```go
_ = store.Save(ctx, book)
return nil
```

Attacks: at-most-once, durability, and any property that assumes a write happened.

**Liveness/readiness conflation.** Health checks the database. During a database outage the orchestrator restarts healthy processes.

Attacks: availability and operability properties.

**Uniform success handler.** A catch-all route returns `200` with an empty body for unknown resources.

Attacks: not-found and validation properties.

## Matching the cheat to the property

| Property shape | Most likely bypass |
|---|---|
| Derived quality metric | no-op reference, metric relocation |
| Persistence | fake storage, deferred side effect, process-local cache |
| Idempotency | arity-only fan-out, empty key |
| Authorisation | missing route, default-allow branch |
| Error surface | error leak, uniform success |
| Availability | liveness/readiness conflation |
| Uniqueness | check-then-insert race |
| Coverage | tautological or weakened assertions |
