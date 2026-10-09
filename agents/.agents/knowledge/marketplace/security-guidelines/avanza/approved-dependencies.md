---
type: Avanza Guideline
title: Dependency and vendor management
description: Pull only from Artifact Registry, pin versions, prefer the Java platform BOM, vet authors, and send new vendors through Tech Procurement.
tags: [avanza, dependencies, artifact-registry, renovate, bom, supply-chain]
---

# Dependency management (High)

Every library is code you trust. Dependencies are a security perimeter. Source: Avanza Technical Security Requirements.

- **Approved sources only.** Avanza Artifact Registry — nothing else. Public Maven Central, npmjs, PyPI, and JitPack are FLAG even if a supporting guide treats extra-index-url as safe.
- **Pin versions** from immutable sources so builds are reproducible from the manifest. Flag `1.+`, `^1.2`, `~1.2`, `latest`, `RELEASE`, `LATEST`, `main-SNAPSHOT`.
- **Java platform BOM.** Use curated platform versions; do not pick library versions ad hoc.
- **Keep current.** Renovate MRs — strive to automerge.
- **Vet package authors** before adopting a new third-party package (maintained? transitive fan-out? security track record?).
- **New external services** go through Tech Procurement.

### Flag

```xml
<url>https://repo.maven.apache.org/maven2</url>      <!-- FLAG -->
```

```gradle
mavenCentral()       // FLAG
```

```toml
url = "https://pypi.org/simple"          # FLAG
```

```json
"registry": "https://registry.npmjs.org/"   // FLAG
```

### Safe

Only `*.artifactregistry.googleapis.com/...` or `nexus.avanza.se` (or the team’s documented internal mirror).

See also [three perimeters](/avanza/three-perimeters.md).
