#!/usr/bin/env node
/**
 * apply-hindsight-issue33-patch.mjs
 *
 * Re-applies the local issue #33 fix to the installed Hindsight coding-agents
 * opencode v2 bundle (`@vectorize-io/hindsight-coding-agents`,
 * dist/opencode2.js). npm installs are not stow-managed, so the patched bundle
 * is reverted by every upgrade/install of the package — run this afterwards.
 *
 * Issue: https://github.com/seppaleinen/dotfiles/issues/33
 *   `bankIdTemplate: "{project}"` resolved to the bare cwd basename, so every
 *   throwaway directory created its own memory bank. Two changes:
 *     (a) the `{project}` resolver now runs the git probe and throws
 *         BankResolutionError when the cwd is not in a repository (never falls
 *         back to dirName(cwd)), and
 *     (b) the opencode SessionStart handler gates on the bundle's own
 *         isOptedIn() before any bank resolution.
 *
 * Idempotent and all-or-nothing: it either applies BOTH textual replacements or
 * none. A partially-patched bundle (one site only) is an error, never a
 * half-applied fix.
 *
 * Usage:
 *   node scripts/apply-hindsight-issue33-patch.mjs [bundlePath]
 *
 * bundlePath defaults to ~/.hindsight/coding-agents/dist/opencode2.js
 * (override with $HINDSIGHT_OPENCODE2_BUNDLE).
 */
import { readFileSync, writeFileSync, renameSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const MARKER =
  "/* HINDSIGHT-PATCH issue#33: {project}=git-probe, isOptedIn wired — re-apply via scripts/apply-hindsight-issue33-patch.mjs */";

/**
 * Each patch: the exact buggy upstream text and the exact replacement.
 * The replacement text here is the single source of truth — it is byte-identical
 * to what is hand-applied to the live bundle, so script and bundle stay in sync.
 */
const PATCHES = [
  {
    name: "(a) {project} resolver: git probe, no dirName fallback",
    old: `    harness: () => harness,
    project: () => dirName(directory),
    gitProject: () => gitProjectName(directory, config3.resolveWorktrees ?? true, sessionRoot),`,
    next: `    harness: () => harness,
    ${MARKER}
    project: () => {
      const mainRoot = mainWorktreeRoot(directory, sessionRoot);
      if (mainRoot.status === "resolved") return basename(mainRoot.root);
      throw new BankResolutionError(
        \`git probe failed for \${directory} (\${mainRoot.status === "failed" ? mainRoot.reason : "no git repository"}) — refusing to guess a bank id\`
      );
    },
    gitProject: () => gitProjectName(directory, config3.resolveWorktrees ?? true, sessionRoot),`,
  },
  {
    name: "(b) opencode SessionStart handler: isOptedIn gate before bank resolution",
    old: `      const dir = projectDir || process.cwd();
      const { cfg, bankId, client } = resolveHostMemory(harness, dir);`,
    next: `      const dir = projectDir || process.cwd();
      ${MARKER}
      const gateCfg = loadConfig({ harness });
      if (!isOptedIn(gateCfg, dir)) {
        log.info(harness, "hindsight: cwd not in optInPaths, skipping memory wiring", { directory: dir });
        return;
      }
      const { cfg, bankId, client } = resolveHostMemory(harness, dir);`,
  },
];

function fail(message) {
  console.error(`apply-hindsight-issue33-patch: ${message}`);
  process.exit(1);
}

const target =
  process.argv[2] ||
  process.env.HINDSIGHT_OPENCODE2_BUNDLE ||
  join(homedir(), ".hindsight", "coding-agents", "dist", "opencode2.js");

let source;
try {
  source = readFileSync(target, "utf8");
} catch (e) {
  fail(`cannot read bundle at ${target}: ${e.message}`);
}

const markerCount = source.split(MARKER).length - 1;
const pending = PATCHES.map((p) => ({
  ...p,
  found: source.includes(p.old),
  occurrences: source.split(p.old).length - 1,
}));

// Already patched: both markers present and no buggy text left anywhere.
if (markerCount === PATCHES.length && pending.every((p) => p.occurrences === 0)) {
  console.log(`apply-hindsight-issue33-patch: already patched, nothing to do (${target})`);
  process.exit(0);
}

// Partially patched, or duplicated/ambiguous match sites — refuse to guess.
if (markerCount !== 0) {
  fail(
    `partial or ambiguous patch state in ${target}: ${markerCount}/${PATCHES.length} marker(s) present; ` +
      `matched originals: ${pending.map((p) => `${p.name}=${p.occurrences}`).join(", ")}. ` +
      `Refusing to apply a partial patch — review the bundle manually.`
  );
}

const allFound = pending.every((p) => p.occurrences === 1);
if (!allFound) {
  fail(
    `the upstream bundle changed — refusing to patch ${target}. ` +
      `Expected exactly one match per site, got: ${pending
        .map((p) => `${p.name}=${p.occurrences}`)
        .join(", ")}. ` +
      `Manual review is required: upstream may have fixed or rewritten this code.`
  );
}

let out = source;
for (const p of pending) out = out.replace(p.old, p.next);

const tmp = `${target}.issue33.tmp`;
writeFileSync(tmp, out, { mode: statSync(target).mode });
renameSync(tmp, target);

console.log(
  `apply-hindsight-issue33-patch: applied ${pending.length} replacement(s) to ${target} ` +
    `(${pending.map((p) => p.name).join("; ")})`
);
