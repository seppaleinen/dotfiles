// rtk command-rewrite hook — DISABLED.
// The plugin installed by `rtk init -g --opencode` hooks `tool.execute.before`
// and throws on `rtk rewrite`'s non-zero exit codes (1 = no rewrite, 3 = rewrite
// found), aborting every shell/bash tool call before execution.
// `rtk.js` was disabled for the same reason in e230b69. Re-land only if it can be
// scoped to interactive/user-initiated input; otherwise leave disabled.
export default { id: "rtk", setup() {} }
