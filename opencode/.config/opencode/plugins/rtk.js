// RTK OpenCode plugin — rewrites commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH.
//
// V2 plugin: registers a tool.execute.before hook that rewrites bash/shell
// commands to use rtk. rtk rewrite exits with code 3 on success, so we capture
// stdout regardless of exit code.

import { spawn, spawnSync } from "node:child_process";

export default {
  id: "rtk",
  setup(ctx) {
    const probe = spawnSync("rtk", ["--version"]);
    if (probe.error) {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled");
      return;
    }

    ctx.tool.hook("execute.before", async (event) => {
      const tool = String(event?.tool ?? "").toLowerCase();
      if (tool !== "bash" && tool !== "shell") return;
      const input = event?.input;
      if (!input || typeof input !== "object") return;
      const command = input.command;
      if (typeof command !== "string" || !command) return;
      try {
        const rewritten = await rewriteCommand(command);
        if (rewritten && rewritten !== command) input.command = rewritten;
      } catch {}
    });
  },
};

function rewriteCommand(command) {
  return new Promise((resolve) => {
    const proc = spawn("rtk", ["rewrite", command]);
    let stdout = "";

    proc.stdout.on("data", (data) => { stdout += data.toString() });
    proc.on("close", () => {
      // rtk rewrite exits with code 3 even on success
      const output = stdout.trim();
      resolve(output || command);
    });
    proc.on("error", () => {
      resolve(command);
    });
  });
}
