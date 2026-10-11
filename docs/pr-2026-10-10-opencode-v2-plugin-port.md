# PR: Port OpenCode plugins from v1 to v2 plugin API

**Branch:** `fix/opencode-v2-crash`

## Summary

Port four OpenCode plugin files from the v1 plugin API (`@opencode-ai/plugin` 1.18.30) to the v2 contract (`@opencode/plugin` 2.0.26), eliminating the EPIPE crash that occurred at plugin load time.

## Scope

| File | Change |
|------|--------|
| `opencode/.config/opencode/herdr-tui-session.js` | Remove dead v1 `tui` entry from `export default`; keep only `{ id, setup }`. Harden `requestOnce`: try/catch around `client.write`, plus `error`/`close` handlers. |
| `opencode/.config/opencode/plugins/herdr-agent-state.js` | Ported v1→v2. v1 event names (`question.asked`/`question.replied`/`question.rejected`/`session.updated`/`session.error`) → v2 names (`form.created`/`form.replied`/`form.cancelled`/`session.renamed`/`session.execution.failed`/`session.compaction.ended`). Export shape changed from async `HerdrAgentStatePlugin` factory + `server()` to `export default { id, setup(ctx) }`. Event subscription moved from the v1 `event` hook to `ctx.event.subscribe()` + `ctx.tool.hook` + `ctx.session.hook` with an AbortController. Defensive try/catch added around the herdr socket write. |
| `opencode/.config/opencode/plugins/paseo-terminal-activity.js` | No changes. Verified v2-clean. Dual-support `server()` entry retained intentionally. |
| `opencode/.config/opencode/plugins/rtk.js` | Ported v1→v2 (replaces deleted `plugins/rtk.ts`). v1 used the `$` shell DSL (`await $\`rtk rewrite ...\``); v2 uses `export default { id: "rtk", setup(ctx) }` with `ctx.tool.hook("execute.before", ...)` and a `spawn`-based rewrite that correctly handles rtk's exit-code-3-on-success via `proc.on("close", ...)` instead of relying on exit code 0. |

## Verification

1. `node --check` passes on all four modified/verified files:
   - `opencode/.config/opencode/herdr-tui-session.js`
   - `opencode/.config/opencode/plugins/herdr-agent-state.js`
   - `opencode/.config/opencode/plugins/paseo-terminal-activity.js`
   - `opencode/.config/opencode/plugins/rtk.js` (v2 port; `rtk.ts` deleted)
2. Start opencode and confirm the log shows zero `failed to load plugin` errors for these four plugins.
3. Confirm the herdr socket write path is intact: trigger a session selection in a herdr pane and verify `pane.report_agent_session` / `pane.report_agent` events are delivered to the herdr socket.

## Breaking Changes

None.

## Follow-up coordination (devops-owned, NOT in this branch)

- **`cli.json` has no `plugins` array.** The herdr-opencode CLI plugin at `herdr-opencode/tui.js` (which re-exports `herdr-tui-session.js`) is not registered anywhere. If the CLI plugin is intended to load, add a `plugins` entry such as `"./herdr-opencode"`.
- **`package.json` pins `@opencode-ai/plugin: 1.18.30`.** This is v1-only types; the runtime provides `@opencode/plugin` 2.0.26. Consider whether the pin should change to match the runtime.
- **`tui.jsonc` / `tui.json`** were already deleted in commit `73a571a` — no action needed.