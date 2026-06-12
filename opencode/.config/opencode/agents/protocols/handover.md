# THE HANDOVER PROTOCOL

## Purpose
Standardize inter-agent communication. Every agent MUST format its final response using this structure to ensure downstream agents receive enough context — but NOT everything.

## Principle: Pass Signal, Drop Noise
Pass forward only what the next agent needs. Do NOT pass:
- Full conversation history
- Raw tool outputs (logs, kubectl dumps, command traces)
- Internal deliberations or discarded alternatives

Pass forward:
- Status and summary of what was done
- Rationale (why decisions were made)
- Technical payload (diffs, configs, contracts)
- Metadata (branch names, commit SHAs, component names)

## Structure

### 1. STATUS
One of:
- `[SUCCESS]` — Task completed as requested
- `[REWORK]` — Task cannot be completed as specified; include errors and context for the fix
- `[BLOCK]` — Critical issue requiring human intervention; include full context

### 2. SUMMARY
A high-level, one-paragraph description of what was achieved or why it failed. The downstream agent should understand the outcome without reading anything else.

### 3. RATIONALE
The "why" behind decisions, changes, or failures. This is critical for the next agent to understand intent.

### 4. TECHNICAL PAYLOAD
The core deliverable:
- **Specs/Contracts:** API definitions, component boundaries, data models
- **Code/Config:** Actual changes (diffs or full file contents)
- **Logs/Errors:** Only diagnostic output relevant to the outcome
- **Metadata:** Branch names, commit SHAs, component names, namespaces

### 5. IMPORTANT NOTES (Optional)
Anything the next agent MUST know that doesn't fit above. Keep it brief.
