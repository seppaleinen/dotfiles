---
name: grafana-cli
description: Grafana operations via curl + jq. Use for dashboards, alerts, datasources.
---

# Grafana CLI Skill

## Purpose
Grafana operations via curl + jq API calls. Use for dashboards, alerts, datasources.

## Always use bash tool with curl + jq, never use MCP tools.

### Common Operations

**List dashboards:**
```bash
bash(command="curl -s https://grafana.labb.site/api/dashboards | jq '.dashboards'")
bash(command="curl -s 'https://grafana.labb.site/api/search?query=production' -H 'Authorization: Bearer $MCP_TOKEN' | jq .")
```

**List datasources:**
```bash
bash(command="curl -s https://grafana.labb.site/api/datasources | jq .")
```

**For alerting rules:**
```bash
bash(command="curl -s 'https://grafana.labb.site/api/v1/rules' -H 'Authorization: Bearer $MCP_TOKEN' | jq .")
```

**Get folder structure:**
```bash
bash(command="curl -s https://grafana.labb.site/api/folders | jq .")
```

**Create/update annotations:**
```bash
bash(command="curl -s -X POST https://grafana.labb.site/api/annotations -H 'Content-Type: application/json' -d '{\"dashboardUID\": \"your-uuid\", \"text\": \"Annotation text\"}' -H "Authorization: Bearer $MCP_TOKEN'")
```

### Environment
- Grafana URL: https://grafana.labb.site
- Auth token: $MCP_TOKEN
- Use `jq` for JSON parsing
- All operations via direct curl API calls
- No CLI binary dependencies required
- MCP_TOKEN environment variable required for authenticated calls