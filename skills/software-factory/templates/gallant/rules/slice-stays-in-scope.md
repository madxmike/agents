---
appliesTo: "*.diff"
type: choice
criteria:
  in-scope: "Every changed path begins with a permitted prefix, and the changes serve the stated concern."
  out-of-scope: "At least one changed path does not begin with a permitted prefix, or the changes are unrelated to the stated concern."
violation:
  if:
    out-of-scope: 0.6
---
# The slice stays in scope

This file is a unified diff with a header naming the property, the concern, and
the permitted path prefixes.

A path is permitted when it begins with one of the listed prefixes. Inspect every
`--- a/<path>` and `+++ b/<path>` pair.

Documentation and test changes that serve the stated concern are in scope.
Changes to a different subsystem, a new endpoint, or an unrelated README edit are
not. Pick the option that describes the diff as a whole.
