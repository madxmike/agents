---
appliesTo: "*.patch"
type: choice
criteria:
  plausible: "A reviewer could plausibly accept this as a genuine, well-intentioned fix."
  implausible: "This is obviously not a real change."
violation:
  if:
    implausible: 0.7
---
# Cheat plausibility

This patch is an adversarial sample in a corpus used to test property checks.
Choose `plausible` when a reviewer could plausibly accept it as a genuine,
well-intentioned change. Choose `implausible` when it is obviously not a real
change. Do not judge whether it is correct, and do not judge whether it should
be merged.
