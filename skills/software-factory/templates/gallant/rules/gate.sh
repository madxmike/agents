#!/bin/sh
# Gate a change with the judged factory checks.
#
#   gate.sh <paths...>                 evaluate files
#   git diff HEAD~1 | gate.sh --diff   evaluate changed files
#
# Current Gallant exits 1 when a check fails and still writes the JSON first;
# v0.4.0 and earlier exit 0. Exit 1 also covers a run error, so this wrapper
# reads the JSON either way. Exits 1 when any finding is blocked, 2 on a run
# error. Set GALLANT_JSON_OUT to keep the artifact for .factory/evidence/.
#
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
	echo "gate.sh: jq is required" >&2
	exit 2
fi

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# A failing check exits 1 on current versions, so do not let set -e abort
# before the JSON is captured.
set +e
if [ "${1:-}" = "--diff" ]; then
	shift
	out=$("$GALLANT" --provider "$PROVIDER" --model "$MODEL" --rules "$HERE" --json --diff)
	status=$?
else
	out=$("$GALLANT" --provider "$PROVIDER" --model "$MODEL" --rules "$HERE" --json "$@")
	status=$?
fi
set -e

if ! printf '%s' "$out" | jq -e 'type == "array"' >/dev/null 2>&1; then
	echo "gate.sh: gallant produced no JSON (exit $status)" >&2
	exit 2
fi

if [ -n "${GALLANT_JSON_OUT:-}" ]; then
	printf '%s\n' "$out" > "$GALLANT_JSON_OUT"
fi

blocked=$(printf '%s' "$out" | jq '[.[] | select(.verdict == "fail" or .type == "noul")] | length')
if [ "$blocked" -eq 0 ]; then
	if [ "$status" -ne 0 ]; then
		echo "gate.sh: gallant exited $status with no blocked findings" >&2
		exit 2
	fi
	printf 'judged checks: clean\n'
	exit 0
fi

printf 'judged checks: %d blocked\n' "$blocked"
printf '%s' "$out" | jq -r '.[] | select(.verdict == "fail" or .type == "noul") | "  \(.file): \(.rule) (\(if (.verdict // "") == "" then "noul" else .verdict end))"'
exit 1
