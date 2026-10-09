# Knowledge Lookup

## What does it do?

Finds and loads relevant org knowledge from the marketplace catalog before relying on general model knowledge. Browses the installed **active set** via `registry.json`, searches the **available** catalog when there is a gap, loads matching OKF knowledge (`index.md` + concepts), and suggests install when relevant knowledge is not yet installed.

## Problems it solves

- Agents relying on general model knowledge when org-specific reference exists
- Inconsistent browse/search steps duplicated across workflow skills
- Missing transparency about which knowledge was loaded, skipped, or suggested

## Example prompts

- "Check if we have org knowledge for Apollo before implementing this"
- "What security policies apply to this change?"
- "Look up org reference for this domain before continuing"

Agents also load this skill when the **knowledge-discovery** rule nudges on non-trivial domain work.

## Requirements

Requires `aza-market` bootstrap. Installed with the **aza-base** package (auto-installed on `aza-market install` bootstrap) or via `aza-market install knowledge-lookup`.
