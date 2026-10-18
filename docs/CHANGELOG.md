# Changelog

## Unreleased

### Changed

- Port four OpenCode plugins from the v1 to the v2 plugin API (`@opencode/plugin` 2.0.26). `herdr-tui-session.js` drops the dead v1 `tui` entry (unreachable in v2, duplicated the `setup` logic) and hardens `requestOnce` against EPIPE on herdr socket writes. `herdr-agent-state.js` is ported v1→v2 (v1 event names → v2, `event` hook → `ctx.event.subscribe()` + `ctx.tool.hook` + `ctx.session.hook`, async factory → `export default { id, setup(ctx) }`). `paseo-terminal-activity.js` was already v2-clean; verified only. `rtk.js` was ported v1→v2 then disabled (`e230b69`): the command-rewrite hook (`ctx.tool.hook("execute.before")` → `rtk rewrite`) conflicts with the opencode tool contract — rtk exits 3 on a *successful* rewrite, which the hook treated as failure and aborted every shell/bash tool call. `plugins/rtk.ts` is now an inert stub (`setup() {}`); the installed `rtk` binary is still used directly by the `flux-cli`/`k8s-cli`/`grafana-cli` skills, and the `rtk-find-loop-prevention` skill is unaffected.

## Removed

- Drop V1 `tui.jsonc` and `tui.json` terminal-client config files. They declared the `herdr-tui-session.js` plugin, which crashes under v2.0.25 due to a v1 herdr plugin API mismatch. Removing them closes the last startup path that could re-instantiate the crashing plugin.