---
name: code-writing-principals
description: Teaches principials to be followed when writing code
disable-model-invocation: false
---

## Perfer Compaction Driven Development
We believe over-abstraction is the cause of many programs spiraling in complexity. Rules such as DRY cause this problem and should be ignored. As such, we take a measured approach with compaction driven development:
 
1. Write the exact code the computer needs in order to accomplish the task. 
2. Look for areas we can "compact" into types, functions, or other structures. 
3. Compact those areas

As a heuristic we should almost never need to compact if code is never used more than once.

This compaction driven development allows abstractions to arise naturally instead of prematurely.

## Perfer Smaller Batch Sizes

Smaller batch sizes for changes result in more readable commits as well as a more readable commit history.

You should commit after finishing a batch of work.
