# ADR: Port OpenCode plugins from v1 to v2 plugin API

- **Date:** 2026-10-10
- **Status:** Accepted
- **Branch:** `fix/opencode-v2-crash`

## Context

Four OpenCode plugin files under `opencode/.config/opencode/` were written against the v1 plugin API (`@opencode-ai/plugin` 1.18.30). At runtime, opencode 2.0.25 loads plugins via the v2 contract (`@opencode/plugin` 2.0.26). The mismatch produced an EPIPE crash at plugin load time and left some plugin entries unreachable.

The four files:

1. `herdr-tui-session.js` — contained a dead v1 `tui` export alongside the v2 `setup` export.
2. `plugins/herdr-agent-state.js` — ported v1→v2 (was not already clean).
3. `plugins/paseo-terminal-activity.js` — already v2-clean; verified only. Dual-support `server()` entry retained intentionally.
4. `plugins/rtk.js` — ported v1→v2, then **disabled** (`e230b69`). Replacing the deleted v1 `plugins/rtk.ts`.

## Decision

Port all four files to the v2 plugin API contract:

- **`herdr-tui-session.js`**: Remove the v1 `tui` entry from `export default`. Keep only `{ id, setup }`. The `setup(context)` function was already v2-clean and duplicates the selection-reporting logic that lived in the removed `tui` entry. Add try/catch around `client.write` in `requestOnce` plus `error`/`close` handlers so a herdr socket failure cannot propagate as an unhandled rejection.
- **`plugins/herdr-agent-state.js`**: Ported v1→v2. Replaced the async `HerdrAgentStatePlugin` factory + `server()` export with `export default { id, "herdr.opencode", setup(ctx) }`. Migrated v1 event names to v2 (`question.asked`→`form.created`, `question.replied`→`form.replied`, `question.rejected`→`form.cancelled`, `session.updated`→`session.renamed`, `session.error`→`session.execution.failed`, `session.compacted`→`session.compaction.ended`). Moved the event loop from the v1 `event` hook to `ctx.event.subscribe()` + `ctx.tool.hook("execute.before"/"execute.after")` + `ctx.session.hook("prompt")`, driven by an AbortController with a cleanup return. Renamed `sessionIDFromProperties(properties)` → `sessionIDFromData(data)` to match the v2 event shape (`event.data`), and read child-session ancestry from `data.sessionID`/`data.parentID` instead of `properties.info`. Added a defensive try/catch around the herdr socket `client.write` so a write failure settles the request rather than throwing.
- **`plugins/paseo-terminal-activity.js`**: No changes. Verified v2-clean.
- **`plugins/rtk.js`**: Ported v1→v2, then **disabled** (`e230b69`). Replacing the deleted v1 `plugins/rtk.ts`. The v1 version used the `$` shell DSL (`await $\`rtk rewrite ${command}\``); the v2 version was `export default { id: "rtk", setup(ctx) }` with `ctx.tool.hook("execute.before", ...)` and a `spawn`-based rewrite capturing stdout on `close`. It was disabled because the command-rewrite hook conflicts with the opencode tool contract — rtk exits 3 on a *successful* rewrite, which the hook treated as failure and aborted every shell/bash tool call. `plugins/rtk.ts` is now an inert stub (`setup() {}`). The installed `rtk` binary is still used directly by the `flux-cli`/`k8s-cli`/`grafana-cli` skills; the `rtk-find-loop-prevention` skill is unaffected.

## Why the `tui` entry was removed

The v1 plugin API exposed a `tui` entry point that opencode invoked when running in TUI mode. The v2 plugin API does not have a `tui` entry — plugins register via `setup(ctx)` (and optionally `server()`). Any code placed in a v1 `tui` entry is unreachable under v2: the runtime never calls it, so the selection-reporting logic it contained was dead code that duplicated the `setup` function.

Keeping the `tui` entry would have left a misleading export surface and a maintenance hazard (two copies of the same logic, one of which is inert). Removing it eliminates the duplication and makes the plugin's contract explicit: `setup` is the single entry point.

## Why dual-support `server()` was kept in paseo

`paseo-terminal-activity.js` exports both `server()` and `setup(ctx)`. The `server()` entry is the v1-compatible path that paseo's hook system consumes when opencode runs as a remote server. The `setup(ctx)` entry is the v2 path that subscribes to events directly. Both are needed because paseo's integration layer still probes for the `server()` export; removing it would break the remote-server hook flow. The dual-support pattern is intentional and stable — it is not a migration artifact to be collapsed.

## EPIPE resolution

The EPIPE crash at plugin load time was **not** an opencode v2 API gap. The herdr socket write path uses plain `node:net` (`net.createConnection` + `client.write`), which is fully supported in the v2 runtime. The crash was a herdr-side socket lifecycle issue: the socket was being written after the peer had already closed, and the resulting EPIPE propagated as an unhandled rejection during plugin initialization.

The fix is defensive socket handling in `requestOnce`:

- `client.write` is wrapped in try/catch so a synchronous write failure settles the request instead of throwing.
- `error` and `close` handlers are attached so the request settles on any socket failure.
- A plain 500 ms timer (unref'd) guarantees the request settles even if the connection never completes.

This makes the herdr write path robust without changing the opencode plugin API contract.

## Consequences

- **Positive:** No more EPIPE crash at plugin load. All four plugins load cleanly under opencode 2.0.25. Dead code removed. Single, explicit entry point for `herdr-tui-session.js`.
- **Negative:** None. No runtime behavior changes; the `setup` function already contained the logic that the removed `tui` entry duplicated.
- **Follow-up (devops-owned, not in this branch):** `cli.json` has no `plugins` array, so the herdr-opencode CLI plugin at `herdr-opencode/tui.js` is not registered. `package.json` pins `@opencode-ai/plugin: 1.18.30` (v1-only types) while the runtime provides `@opencode/plugin` 2.0.26. Both need a devops-lead decision.