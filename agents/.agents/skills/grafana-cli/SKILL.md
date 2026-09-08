---
name: grafana-cli
description: Grafana operations via grafanaactl CLI or curl + jq. Use for dashboards, alerts, datasources.
---

# Grafana CLI Skill

## Purpose
Grafana operations via grafanaactl CLI or curl + jq. Use for dashboards, alerts, datasources.

## Always use bash tool with grafanaactl or curl + jq, never use MCP tools.

### Common Operations

**List dashboards:**
```bash
bash(command="grafanaactl resources list")
bash(command="curl -s https://grafana.labb.site/api/dashboards | jq '.dashboards'")
```

**Search dashboards:**
```bash
bash(command="grafanaactl resources search dashboard")
bash(command="curl -s 'https://grafana.labb.site/api/search?query=production' -H 'Authorization: Bearer $MCP_TOKEN' | jq .")
```

**List datasources:**
```bash
bash(command="curl -s https://grafana.labb.site/api/datasources | jq .")
bash(command="rtk kubectl config view --minify")  # fallback context
```

**Create/Update annotations:**
```bash
bash(command="curl -s -X POST https://grafana.labb.site/api/annotations -H 'Content-Type: application/json' -d '{\"dashboardUID\": \"your-uuid\", \"text\": \"Annotation text\"}' -H "Authorization: Bearer $MCP_TOKEN'")
```

**For alerting rules:**
```bash
bash(command="curl -s 'https://grafana.labb.site/api/v1/rules' -H 'Authorization: Bearer $MCP_TOKEN' | jq .")
```

### Environment
- Grafana URL: https://grafana.labb.site
- Auth token: $MCP_TOKEN
- Use `jq` for JSON parsing
- grafanaactl is available for compact resource listing
- Direct curl API calls work for all operations
```
