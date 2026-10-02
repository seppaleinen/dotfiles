---
name: delegation-contract
description: Delegation rules for pipeline leads: task()-only dispatch, subagent_depth=2 cap, pass Research Brief + constraint summary + expected output format, never pass conversation history or raw tool output.
---

# Delegation Contract

## Mechanism
All coordination is via the `task()` tool (synchronous — the caller blocks until the subagent returns). Never delegate by spawning separate agents (paseo `create_agent`/`send_agent_prompt`, herdr tab-spawns, or manual Tab-switching between primary agents).

## Depth Cap
Max **2 layers** from `team-lead` (`subagent_depth: 2` in `opencode.json`). Deepest chains are `team-lead → dev-team-lead → worker` and `team-lead → researcher → web-scout`. Do NOT change `subagent_depth` in opencode.json. Keep pipelines within this budget; flatten deeper chains or escalate.

## What to Pass
- The Research Brief file path
- A summary of the key constraints from the brief
- The expected output format

## What NOT to Pass
- Full conversation history
- Raw tool output from prior exploration
- Internal routing logic

## Context Discipline
Each dispatch gets a fresh `task` call. Do NOT chain dispatches in a single call. Wait for the result, evaluate it, then dispatch the next step if needed.