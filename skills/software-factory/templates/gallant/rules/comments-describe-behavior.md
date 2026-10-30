---
appliesTo: "*.go"
type: choice
criteria:
  accurate: "Every doc comment describes what the code actually does, and adds something the signature does not already say."
  restating: "At least one comment only restates what the code plainly does, such as `// Add adds.` above `func Add`."
  misleading: "At least one comment claims behavior, a type, or a direction that the code beneath it does not implement."
violation:
  if:
    restating: 0.6
    misleading: 0.6
---
# Comments describe actual behavior

Judge the doc comments in this file.

A good comment explains intent, a constraint, a unit, or a non-obvious choice. A
comment that only restates the signature is noise. A comment that names a
different type or form than the code uses is wrong.

Ignore tooling directives such as build tags, `//go:generate`, and `//nolint`.
Pick the option that describes the file as a whole.
