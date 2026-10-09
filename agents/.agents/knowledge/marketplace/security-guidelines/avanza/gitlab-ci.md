---
type: Avanza Guideline
title: GitLab CI and security tooling
description: No GitLab secure_files for secrets. Protect main, four-eyes on production-bound branches, guard pipeline IAM, enroll the security pipeline.
tags: [avanza, gitlab-ci, secure-files, secrets, ci-cd, sonar, dependency-track]
---

# CI/CD, build security, and security tooling (High)

A GitLab repo is code execution (pipelines), often with GCP permissions. Source: Avanza Technical Security Requirements.

## Do not use GitLab "secure files"

Files are UI-visible to maintainers only, but **every Developer can download them via the API**. Any compromised Tech account can enumerate them. Use Vault or GCP Secret Manager via Workload Identity.

```yaml
- secure_files_download                                # FLAG
- curl --header "JOB-TOKEN: $CI_JOB_TOKEN" \
       "$CI_API_V4_URL/projects/$CI_PROJECT_ID/secure_files/..."  # FLAG
```

## Protected branches and four-eyes

`main` must be protected. Merges require review. Code merged to a production-bound branch must be approved by at least two people (platform-enforced). Same for any branch where a modified pipeline can run IaC or poison production artifacts.

## Guard pipeline permissions

IAM tied to pipelines must not be abusable by non-team users (for example an MR that edits `.gitlab-ci.yml`). For multi-tenant GitOps repos, a compromised account in team A must not affect team B’s resources.

### Flag

- Jobs with broad IAM (`gcloud auth activate-service-account`, terraform with project-wide roles) **without** `rules:` limiting to protected branches / code-owner paths
- `if: $CI_PIPELINE_SOURCE == "merge_request_event"` assuming a privileged identity
- Privileged `include:` with missing `ref:` or `ref: $CI_COMMIT_REF_NAME` (`ref: main` is acceptable)
- Unprotected `main` or single-approver production merges where four-eyes should apply

## Security tooling (Production / Internal classification)

None of these tools are perfect. Do not ignore findings because they “look like” false positives — raise them so rules can be tuned.

- **Static analysis**: enroll in the common security pipeline. Jenkins `azaPipeline` is enrolled by default. GitLab:

```yaml
include:
- component: $CI_SERVER_FQDN/avanzabank/Tech/TeamAppSec/security-toolkit/pipeline@main
```

- **Third-party vulns**: Dependency-Track, reported in Backstage.
- **GCP Security**: team project → Security product tab.

Further reading: [Code classification](https://wiki.avanza.se/spaces/IUD/pages/324567228/Kodklassificering+Dualitet+i+Gitlab), [Pipeline security](https://wiki.avanza.se/spaces/UTV/pages/260839453/Pipeline+security), [Multi-tenant GitLab pipelines](https://wiki.avanza.se/spaces/UTV/pages/319455454/Multi-tenant+Gitlab+Repo+Pipelines).

See also [sensitive changes](/avanza/sensitive-changes.md).
