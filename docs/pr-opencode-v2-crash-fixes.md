# Drop V1 tui.jsonc and tui.json

## Summary

Delete the last two V1 terminal-client config files so the v2 OpenCode client can no longer re-instantiate the crashing herdr plugin at startup.

## Changes

- **Deleted** `opencode/.config/opencode/tui.json` — V1 config declaring the `herdr-tui-session.js` plugin.
- **Deleted** `opencode/.config/opencode/tui.jsonc` — V1 config (JSON with comments) declaring the same plugin.

## Testing

- Confirmed neither file is referenced by `opencode.json`, `service.json`, or any agent config.
- Verified the v2 client starts without these files present.
- Bisection already confirmed the client runs stable outside herdr; removal does not change that behavior.

## Breaking Changes

None. Files were V1-only and unreferenced by the v2 runtime.

## Remaining Risks

- Herdr-managed `opencode --auto` sessions still exit every 2–5 minutes. The root cause is a v1 herdr plugin API mismatch with v2.0.25 (H1). A herdr-side plugin port is required to restore session persistence under herdr — tracked by dev-team-lead.