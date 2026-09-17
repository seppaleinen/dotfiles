---
name: flux-cli
description: Flux GitOps operations via flux CLI. Use for GitHub repositories, HelmReleases, Kustomizations, and cluster debugging.
---

# Flux CLI Skill

## Purpose
Flux GitOps operations via `flux` CLI (v2.9.4). Use for GitHub repositories, HelmReleases, Kustomizations, and cluster debugging.

## Always use bash tool with `flux` CLI, never use MCP tools.

### Common Operations

**List Git repositories:**
```bash
bash(command="flux get sources git --all-namespaces")
bash(command="rtk flux get sources git --all-namespaces")
```

**List HelmReleases:**
```bash
bash(command="flux get helmreleases --all-namespaces")
bash(command="rtk flux get helmreleases --all-namespaces")
```

**List Kustomizations:**
```bash
bash(command="flux get kustomizations --all-namespaces")
bash(command="rtk flux get kustomizations --all-namespaces")
```

**Get flux instance status:**
```bash
bash(command="flux get fluxinstance")
bash(command="rtk kubectl get deployment flux-operator-controller-manager -n flux-system")
```

**Check cluster health:**
```bash
bash(command="flux check --components")
bash(command="kubectl get nodes -A")
```

### Cluster Context Management
```bash
bash(command="kubectl config current-context")
bash(command="kubectl config get-contexts")
```

### Debugging Workflows

**Install Flux Operator:**
```bash
bash(command="flux install")
```

**Check controller status:**
```bash
bash(command="kubectl get pods -n flux-system -l fluxcd.io/control-plane=flux-controller")
bash(command="kubectl logs deployment/flux-operator-controller-manager -n flux-system --tail=50")
```

**Get Flux reports:**
```bash
bash(command="flux get fluxreport")
bash(command="rtk flux get fluxreport")
```

### Environment
- Flux CLI v2.9.4 installed
- kubeconfig configured (kubectl works)
- Use `rtk` for compact output
- Works with both KinD, K3s, and full Kubernetes clusters
- Flux reports available for cluster-wide status