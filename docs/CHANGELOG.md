# Changelog

## Unreleased

### Changed

- Port four OpenCode plugins from the v1 to the v2 plugin API (`@opencode/plugin` 2.0.26). `herdr-tui-session.js` drops the dead v1 `tui` entry (unreachable in v2, duplicated the `setup` logic) and hardens `requestOnce` against EPIPE on herdr socket writes. `herdr-agent-state.js` is ported v1→v2 (v1 event names → v2, `event` hook → `ctx.event.subscribe()` + `ctx.tool.hook` + `ctx.session.hook`, async factory → `export default { id, setup(ctx) }`). `paseo-terminal-activity.js` was already v2-clean; verified only. `rtk.js` is ported v1→v2, replacing the deleted v1 `plugins/rtk.ts` (`$` shell DSL → `export default { id, setup(ctx) }` with `ctx.tool.hook` and a `spawn`-based rewrite that handles rtk's exit-code-3-on-success).

## Removed

- Drop V1 `tui.jsonc` and `tui.json` terminal-client config files. They declared the `herdr-tui-session.js` plugin, which crashes under v2.0.25 due to a v1 herdr plugin API mismatch. Removing them closes the last startup path that could re-instantiate the crashing plugin.