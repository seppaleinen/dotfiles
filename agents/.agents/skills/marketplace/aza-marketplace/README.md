# aza Marketplace

## What does it do?

Teaches the AI agent how to use the `aza-market` CLI — Avanza's internal tool for discovering, installing, updating, and managing agent components (skills, rules, hooks, agents, commands, MCP servers, and packages) from the agent marketplace.

## Problems it solves

- AI agents not knowing how to find or install marketplace components
- Forgetting the correct `aza-market` command syntax mid-session
- Confusion about component types, install scopes, and install paths
- Debugging why a component is not auto-updating (e.g. it is pinned)
- Not knowing how to browse the marketplace without leaving the editor

## Example prompts

- "What skills are available in the marketplace?"
- "Install the python-expert skill for this project"
- "Why is my skill not auto-updating?"
- "Show me what components I have installed"
- "Pin the python-expert skill so it does not auto-update"
- "How do I add a hook from the marketplace?"

## Requirements

`aza-market` CLI must be installed. Run the bootstrap one-liner from the repo README if it is not set up yet.
