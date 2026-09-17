---
name: k8s-cli
description: Kubernetes operations via kubectl CLI. Use for pod/service/deployment management, logging, and cluster operations.
---

# K8s CLI Skill

## Purpose
Kubernetes operations via kubectl CLI. Use for pod/service/deployment management, logging, and cluster operations.

## Always use bash tool with kubectl, never use MCP tools.

### Common Operations

**List pods:**
```bash
bash(command="kubectl get pods -n <namespace>")
bash(command="rtk kubectl get pods -A")
```

**Get deployment details:**
```bash
bash(command="kubectl get deployment <name> -n <namespace> -o yaml")
```

**View logs:**
```bash
bash(command="kubectl logs <pod-name> -n <namespace> --tail=50")
```

**Apply changes:**
```bash
bash(command="kubectl apply -f <file>")
```

**Use rtk for token-optimized output:**
```bash
bash(command="rtk kubectl get pods -A")
bash(command="rtk flux get kustomizations --namespace prod")
bash(command="rtk kubectl logs <pod-name> -n <namespace>")
```

### Environment
- kubectl configured at ~/.kube/config
- Use `kubectl get <resource> -A` for all namespaces
- Use `kubectl describe <resource> <name> -n <namespace>` for details
- Use `rtk` commands for compact output
- Flux commands available via `flux` binary (2.9.4)

### Additional Flux Commands
```bash
bash(command="flux get kustomizations --namespace prod")
bash(command="flux get helmreleases --namespace prod") 
bash(command="flux get sources git --namespace prod")
```