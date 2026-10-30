#!/bin/sh
# Run each factory rule against its labelled samples.
#
# Requires: a gallant binary on PATH, jq, and a provider credential.
#   GALLANT_PROVIDER  default opencode
#   GALLANT_MODEL     default jev-1.13
#   GALLANT           default gallant
set -eu

# Load the user's credentials and model defaults when the calling shell did not.
if [ -z "${GALLANT_MODEL:-}" ] && [ -f "${HOME:-/nonexistent}/.config/gallant/env" ]; then
	. "${HOME}/.config/gallant/env"
fi

PROVIDER="${GALLANT_PROVIDER:-opencode}"
MODEL="${GALLANT_MODEL:-jev-1.13}"
GALLANT="${GALLANT:-gallant}"

if [ "$PROVIDER" = "opencode" ]; then
	: "${OPENCODE_API_KEY:?set OPENCODE_API_KEY}"
fi

if ! command -v jq >/dev/null 2>&1; then
	echo "run_golden.sh: jq is required" >&2
	exit 2
fi

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

failures=0
total=0

while IFS='|' read -r rule sample expect note; do
	case "$rule" in ''|'#'*) continue ;; esac
	total=$((total + 1))

	# Isolate the rule under test so other rules cannot affect the verdict.
	tmp=$(mktemp -d)
	cp "$HERE/$rule.md" "$tmp/"

	# A failing sample exits 1 on current versions, so capture stdout first.
	set +e
	out=$("$GALLANT" --provider "$PROVIDER" --model "$MODEL" \
		--rules "$tmp" --json "$HERE/$sample" 2>/dev/null)
	set -e
	rm -rf "$tmp"

	if ! printf '%s' "$out" | jq -e 'type == "array"' >/dev/null 2>&1; then
		printf 'ERROR    %-44s could not evaluate\n' "$sample"
		failures=$((failures + 1))
		continue
	fi

	blocked=$(printf '%s' "$out" | jq '[.[] | select(.verdict == "fail" or .type == "noul")] | length')
	if [ "$blocked" -gt 0 ]; then got=fail; else got=pass; fi

	if [ "$got" = "$expect" ]; then
		printf 'ok       %-44s %s\n' "$sample" "$note"
	else
		printf 'MISMATCH %-44s want=%s got=%s\n' "$sample" "$expect" "$got"
		failures=$((failures + 1))
	fi
done < "$HERE/expectations.tsv"

printf '\n%d/%d samples matched\n' "$((total - failures))" "$total"
[ "$failures" -eq 0 ]
