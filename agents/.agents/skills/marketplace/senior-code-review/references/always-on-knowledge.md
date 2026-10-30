# Always-on knowledge

On every review, load installed knowledge that matches the policy below — before change-specific lookup. Follow the **knowledge-lookup** skill for registry reading, catalog search, and install recommendations.

## Policy

**Tags** — load every installed registry entry whose `tags` include any of:

- `security`
- `appsec`
- `compliance`

**Names** — load every installed registry entry whose registry `name` matches any of:

- *(none yet — add explicit names here when a knowledge entry should be always-on without sharing a broad tag)*

## After always-on

Run the **knowledge-lookup** skill for change-specific domains using confirmed intent and what the diff touches. Skip entries already loaded as always-on.

## Record in Transparency

**Always-on knowledge:** names loaded | `suggested install: <name> — <one-line why>` | `catalog search: no matches for <tags tried>` | `policy empty`
