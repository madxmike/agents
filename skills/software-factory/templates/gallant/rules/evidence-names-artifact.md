---
appliesTo: "evidence.md"
type: choice
criteria:
  complete: "Every evidence claim names the file, command, or model that establishes it, and the claimed class matches that check."
  incomplete: "At least one claim is missing its artifact, or claims a stronger class than the check supports."
violation:
  if:
    incomplete: 0.6
---
# Evidence names its artifact

Judge the evidence entries in this file.

A `tested` entry must name the test or command. A `bounded-proved` or `proved`
entry must name the model and its bound or premises. An `assumed` entry must
name the premise and what would validate it.

A claim with no artifact, or a class stronger than the check supports, is
incomplete.
