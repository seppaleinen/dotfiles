# Delete V1 tui.jsonc and tui.json

Remove V1 terminal-client config files that re-instantiate the crashing herdr plugin at startup.

---

## Status

Accepted

---

## Context

OpenCode v2.0.25 sessions managed by herdr exited every 2–5 minutes. Bisection isolated the failure to the herdr side: a v1 herdr plugin API mismatch with the v2 runtime. Running the client outside herdr produced stable sessions. Two V1-era config files — `tui.jsonc` and `tui.json` — declared the `herdr-tui-session.js` plugin and were the last remaining path that could re-instantiate the crashing plugin at startup.

---

## Decision

Delete `opencode/.config/opencode/tui.jsonc` and `opencode/.config/opencode/tui.json`. The v1-to-v2 migration is complete; the client runs clean outside herdr; these files are dead weight. No config references them.

---

## Consequences

- Positive: closes the last startup path that could re-instantiate the crashing plugin.
- Positive: reduces config surface area; removes a V1/V2 compatibility hazard.
- Negative: none observed. Files were V1-only and unreferenced by the v2 runtime.
- Follow-up: herdr-side plugin port is still needed (tracked by dev-team-lead) to restore session persistence under herdr.