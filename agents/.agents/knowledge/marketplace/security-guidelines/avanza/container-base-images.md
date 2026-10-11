---
type: Avanza Guideline
title: Container base images
description: Production GCP workloads should use platform-area base images, not ad-hoc public images.
tags: [avanza, docker, base-images, containers, gcp]
---

# Container base images

Production workloads in GCP should use base images maintained by the platform area.

Source: Avanza Technical Security Requirements.

### Flag

`FROM` a random public image for a production service when a platform base image exists. Unpinned `latest` tags.

Further reading: [custom-containers base-images](https://gitlab.com/avanzabank/Tech/TeamLP/gcp/custom-containers/-/tree/main/base-images).
