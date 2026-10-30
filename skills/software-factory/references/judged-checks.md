# Judged checks

A judged check is a probabilistic decision over text. It answers questions a parser cannot: whether a comment matches the code, whether a diff stays inside its declared concern, whether an error message discloses internals.

Use it when no deterministic check exists. Do not use it to decide whether a property holds.

## Evidence class

`judged` sits between `tested` and `assumed`:

| class | a failure means | a pass means |
|---|---|---|
| `tested` | the property is false | the property held on the inputs tried |
| `judged` | a signal; confirm before acting | the text did not obviously violate the rule |
| `assumed` | nothing; the premise was never tested | nothing |

A judged result never promotes a property above `tested` on its own. If a property has only judged evidence, record `judged`, not `tested`.

## Tool: Gallant

Gallant evaluates markdown rules against input text with a decision model. The behaviour below was checked against `cmd/gallant/main.go` and `rules/rules.go`.

**Invocation**

- `--rules <dir>` selects the rule directory. The default is `.agents/gallant`.
- `--json` emits an array of records: `{file, rule, type, verdict, reason, results}`.
- `--diff` reads a unified diff from stdin. Each changed file becomes one evaluation, named by its path.
- `appliesTo` matches the **basename** of the input, not the path. `*.go` matches `internal/isbn/isbn.go`.
- `GALLANT_PROVIDER`, `GALLANT_MODEL`, and `GALLANT_RULES` supply defaults. An empty value counts as unset, and a flag overrides its variable. `--jobs` must be at least 1.

**Exit status.** Current upstream (`265f518` and later) exits `1` when at least one check fails, and still writes the JSON array to stdout before exiting. `v0.4.0` and earlier exit `0` even when checks fail. Because `1` also covers a run error, a gate should parse the JSON rather than trust the status alone.

**Rule shape.** Prefer `choice` over `noul` for prose rules. On Jev 1.13, `noul` rules with prose bodies returned near-0.5 probabilities regardless of content (an empty Go file scored 0.49 fail), while a `choice` rule with named options discriminated cleanly (0.95 versus 0.05 on the repository's own example). Give the model two or three named options and a `violation.if`.

**Reading the JSON**

- A `noul` record appears only when the probability of violation exceeds the rule's `minConfidence`, unless `--include-passing` is set. Its presence therefore means violation.
- A `choice` or `score` record emits a `verdict` only when the rule declares `violation:`. Every judged rule must declare one, or the gate has nothing to read.
- The gate condition is:

```
blocked = count(records where verdict == "fail" or type == "noul")
```

- Capture stdout even when the exit status is 1. The JSON is written before the process exits, so a script that aborts on a nonzero status loses the findings.

**Scope limits**

- `--diff` evaluates each changed file separately. A rule cannot see the whole diff. For diff-wide properties such as scope or attribution, save the diff to a file and evaluate it in file mode with `appliesTo: "*.diff"`.
- The model context is small. Only file-scoped or hunk-scoped properties are viable.
- The tool never executes anything. Persistence, status codes, idempotency, and concurrency are permanently out of scope.

## Pinning

Record in the evidence artifact:

- provider and model name
- hash of the rule file
- threshold
- date

A model update changes the probabilities. An unpinned gate drifts without anyone editing it.

```yaml
- class: judged
  artifact: .factory/evidence/S03.gallant.json
  rule: comments-describe-behavior
  model: opencode/jev-1.13
  rule_sha256: 6f1c...
  threshold: 0.8
  recorded_at: 2026-10-29
```

## Calibration

1. Collect roughly 50 known-good and 50 known-bad samples per rule.
2. Run each rule against both sets.
3. Compute precision and recall at candidate thresholds.
4. Choose a threshold the gate can defend, and store the result in `.factory/judged/calibration.md`.
5. Re-run after any model or rule change.

An uncalibrated threshold is a guess dressed as a policy.

## Bands

The rule's `minConfidence` already filters what is emitted. Band what remains:

| confidence | action |
|---|---|
| >= 0.9 | block |
| 0.6 - 0.9 | warn, and require a one-line disposition from the author |
| < 0.6 | ignore |

Calibration overrides these defaults. The warning band exists so the gate can stay fail-closed while not blocking on every borderline judgment.

## Adversarial text

A judge reads text the author controls. Text can contain instructions, and a decision model may follow them. Do not run judged rules over untrusted content, and do not treat a judged pass as evidence about who wrote the text.

## Corpus

Every judged rule needs a cheat corpus, more than a deterministic rule does, because the model is the thing being fooled. A comment that claims "verified against production" is not verification, and a rule that scores it as verification is a liability. Pair each rule with labelled good and bad samples and run them with a golden script.

## Repository layout

Gallant loads **every** `.md` under the rules directory, recursively, and fails on parse errors. Keep sample files out of the loader's path:

- put samples in a hidden subdirectory (`rules/.testdata/`), which `Load` skips, or outside the rules directory entirely
- keep expectations and scripts as non-`.md` files
- do not add a `README.md` inside the rules directory

## Where to use it

| Check | Deterministic option | Judged role |
|---|---|---|
| Does the slice stay in its declared concern? | diff paths vs scope | secondary |
| Do comments describe actual behavior? | none | primary |
| Does a commit or ledger claim evidence it does not have? | schema validation | secondary |
| Is an error message client-safe? | contract test | secondary |
| Does a test weaken an assertion? | AST diff | secondary |
| Does this patch look like a genuine fix? | reviewer judgment | primary (corpus calibration) |
| Does the property hold? | test or model check | never |
