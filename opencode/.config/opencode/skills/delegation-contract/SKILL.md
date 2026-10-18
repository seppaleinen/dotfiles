---
name: delegation-contract
description: Delegation rules for pipeline leads: subagent()-only dispatch, subagent_depth=2 cap, pass Research Brief + constraint summary + expected output format, never pass conversation history or raw tool output.
---

# Delegation Contract

## Mechanism
All coordination is via the `subagent()` tool (synchronous — the caller blocks until the subagent returns). Never delegate by spawning separate agents (paseo `create_agent`/`send_agent_prompt`, herdr tab-spawns, or manual Tab-switching between primary agents).

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

## Dispatch Prompt Contract (issue #8)

A dispatch prompt states **WHAT** must be produced and **WHAT CONSTRAINTS** apply. It does **NOT** dictate **HOW** the lead stages the work.

**Never pass an implementation blueprint.** An implementation blueprint includes any of:

- Exact file layout or directory structure to create
- Exact schema definitions (e.g. `values.yaml` field-for-field)
- Exact test commands or verification procedures
- Exact values, counts, or configuration literals
- A step-by-step "do this, then that" work plan

**Pass instead:** the Research Brief + constraint summary + expected output format. The lead decides which pipeline stages to run, in what order, and which agents to dispatch. The caller's job is to specify the destination and the guardrails — not the route.

**Why:** A dispatch prompt that is an implementation spec overrides the lead's "do not implement, coordinate" role. The lead then implements inline (zero `subagent()` calls), the pipeline trace collapses to a single stage, and no gate can recover the missing stages. The dispatch prompt is the first and best defense against trace collapse.

## Context Discipline
Each dispatch gets a fresh `subagent` call. Do NOT chain dispatches in a single call. Wait for the result, evaluate it, then dispatch the next step if needed.

## Handover Validation
Before accepting a subagent result, mechanically validate that the handover contains all required fields:
- **STATUS** — must be `[SUCCESS]`, `[REWORK]`, `[BLOCK]`, or `[STUCK]`
- **SUMMARY** — plain-language summary of the outcome
- **RATIONALE** — decisions made and why
- **TECHNICAL PAYLOAD** — files changed, test results, or output artifacts
- **TRACE** — full dispatch chain showing the full pipeline path

Reject incomplete handovers immediately. Do not propagate partial results. If STATUS is missing or fields are empty, request a complete handover before proceeding to verification or synthesis.