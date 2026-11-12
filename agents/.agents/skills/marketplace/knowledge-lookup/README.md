# Knowledge Lookup

## What does it do?

Lets agents answer from your org's installed knowledge (security requirements, platform conventions, business-domain rules) when a task depends on it, instead of guessing from general model knowledge. It loads only the parts that match the task, respects which knowledge your repo allows, and tells you which knowledge it used.

## Problems it solves

- Agents answering org-policy questions from general model knowledge when your org has documented the answer
- Agents pulling in unrelated org knowledge, wasting context on tasks that don't need it
- Not knowing which org knowledge shaped an answer
- Not knowing that relevant org knowledge exists but isn't installed

## Example prompts

- "Check if we have org knowledge for Apollo before implementing this"
- "What security policies apply to this change?"
- "Follow the java-platform knowledge for this change"

## Requirements

Requires `aza-market` bootstrap. Installed with the **aza-base** package (auto-installed on `aza-market install` bootstrap) or via `aza-market install knowledge-lookup`.
