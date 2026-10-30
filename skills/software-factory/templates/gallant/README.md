# Gallant rules for the software-factory loop

Five judged checks covering text properties that no deterministic check can settle. They are templates: copy `rules/` into a project and run them with an explicit rules directory.

## Install

```sh
cp -R templates/gallant/rules <project>/.agents/gallant/factory
```

Run with the explicit directory:

```sh
gallant --provider opencode --model jev-1.13 \
  --rules .agents/gallant/factory <paths...>
```

## Why the explicit `--rules`

Gallant loads `.agents/gallant` recursively by default. If you copy these rules into `.agents/gallant/factory`, a bare `gallant .` will also apply the `*.go` rules to every Go file in the repository. Use the explicit directory for factory checks, and keep the default set for ordinary linting.

## Gate

`rules/gate.sh` reads the JSON array and exits nonzero when any finding is blocked. Gallant exits 1 on a failed check from commit `265f518` onward, but `v0.4.0` and earlier exit 0, and exit 1 also covers run errors, so the wrapper parses the output.

Current versions also accept `GALLANT_PROVIDER`, `GALLANT_MODEL`, and `GALLANT_RULES` as defaults; the flags in these scripts override them.

```sh
# paths
rules/gate.sh internal/isbn internal/httpapi

# changed files
git diff HEAD~1 | rules/gate.sh --diff
```

Set `GALLANT_JSON_OUT` to persist the artifact for `.factory/evidence/`.

## Calibration

`rules/run_golden.sh` runs each rule against its labelled samples in `rules/.testdata/`. It requires `jq`, a model credential, and a `gallant` binary on `PATH`.

```sh
go build -o /tmp/gallant ./cmd/gallant
PATH=/tmp:$PATH ./templates/gallant/rules/run_golden.sh
```

Ten samples is enough to confirm the rules are wired correctly. It is not enough to calibrate a threshold. See `references/judged-checks.md` in the skill for the calibration procedure.

## Layout constraint

Gallant parses every `.md` file under the rules directory and fails on a file without frontmatter. The samples therefore live in `.testdata/`, which `Load` skips because the directory name begins with a dot. Do not add a `README.md` or any other `.md` file to the rules directory.
