---
name: authentik-cli
description: Authentik operations via curl + jq API calls. Use for user management, groups, and applications.
---

# Authentik CLI Skill

## Purpose
Authentik operations via curl + jq API calls. Use for user management, groups, and applications.

## Always use bash tool with curl + jq, never use MCP tools.

### Common Operations

**List users:**
```bash
bash(command="curl -s https://authentik.labb.site/api/v3/core/users/ -H 'Authorization: Bearer $MCP_TOKEN' | jq '.results[] | {id, username, email, is_active}'")
bash(command="curl -s https://authentik.labb.site/api/v3/core/users/ -H 'Authorization: Bearer $MCP_TOKEN' | jq '.count'")
```

**Create user:**
```bash
bash(command="curl -s -X POST https://authentik.labb.site/api/v3/core/users/ -H 'Content-Type: application/json' -H 'Authorization: Bearer $MCP_TOKEN' -d '{\"username\": \"newuser\", \"email\": \"user@example.com\", \"name\": \"New User\"}'")
```

**List groups:**
```bash
bash(command="curl -s https://authentik.labb.site/api/v3/core/groups/ -H 'Authorization: Bearer $MCP_TOKEN' | jq '.results[] | {id, name, slug}'")
bash(command="curl -s https://authentik.labb.site/api/v3/core/groups/ -H 'Authorization: Bearer $MCP_TOKEN' | jq '.count'")
```

**Create group:**
```bash
bash(command="curl -s -X POST https://authentik.labb.site/api/v3/core/groups/ -H 'Content-Type: application/json' -H 'Authorization: Bearer $MCP_TOKEN' -d '{\"name\": \"newgroup\", \"slug\": \"newgroup\"}'")
```

**List applications:**
```bash
bash(command="curl -s https://authentik.labb.site/api/v3/core/applications/ -H 'Authorization: Bearer $MCP_TOKEN' | jq '.results[] | {id, name, slug, provider}'")
bash(command="curl -s https://authentik.labb.site/api/v3/core/applications/ -H 'Authorization: Bearer $MCP_TOKEN' | jq '.count'")
```

**Create application:**
```bash
bash(command="curl -s -X POST https://authentik.labb.site/api/v3/core/applications/ -H 'Content-Type: application/json' -H 'Authorization: Bearer $MCP_TOKEN' -d '{\"name\": \"new-app\", \"slug\": \"new-app\", \"provider\": 1, \"authorization_server\": 1}'")
```

### Environment
- Authentik URL: https://authentik.labb.site
- Auth token: $MCP_TOKEN
- Use `jq` for JSON parsing
- curl + jq for all operations
- API v3 endpoints used (adjust if using different version)