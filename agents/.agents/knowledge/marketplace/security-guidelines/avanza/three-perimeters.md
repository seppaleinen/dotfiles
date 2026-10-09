---
type: Avanza Guideline
title: Three perimeters
description: Identity (least privilege, Workload Identity, PAM), network (GKE NetworkPolicy, predetermined paths), and workload/supply chain. Treat other teams as separate customers.
tags: [avanza, gcp, iam, network-policy, workload-identity, pam]
---

# Three perimeters in practice

Attackers breach via identity, network, and workload/supply chain. Apply compensating controls on all three.

Source: Avanza Technical Security Requirements.

## Identity

Credentials for a GCP identity (service-account access token) are devastating in the wrong hands.

- Least privilege for service accounts and humans.
- Avoid long-lived credentials. Use Workload Identity and short-lived credentials.
- Limit standing human privileges on production. Use PAM for temporary elevation.
- If the team exposes services to other teams: treat those teams as **separate customers**. A compromised developer in team A must not exploit team B’s resources.

## Network

Traffic through predetermined paths, logged, and protected. Every GKE workload should have a Network Policy restricting ingress **and** egress to what it needs. Workloads on appropriate subnets with narrow firewalls. Sensitive on-prem workloads on dedicated hostgroups where possible.

## Workload / supply chain

Assess dependencies, pull from approved sources, keep current — [dependencies](/avanza/approved-dependencies.md).

Further reading: [Application Security at Avanza](https://wiki.avanza.se/spaces/UTV/pages/338986528/Application+Security+at+Avanza).

See also [IaC and hands-off production](/avanza/iac-production.md).
