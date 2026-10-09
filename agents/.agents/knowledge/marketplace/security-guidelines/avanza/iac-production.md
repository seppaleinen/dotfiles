---
type: Avanza Guideline
title: IaC and hands-off production
description: Define infrastructure in Git with Terraform. Manual production access is the exception — use PAM for time-limited, audited access.
tags: [avanza, terraform, iac, pam, production]
---

# Infrastructure as code and hands-off production

Build systems that solve production problems without manual intervention. Infrastructure belongs in Git (Terraform). Manual production access is the exception. When needed, use PAM for time-limited, audited access.

Source: Avanza Technical Security Requirements.

### Flag

Click-ops as the documented normal path. Standing human owner/editor on prod. Terraform in an unprotected branch with privileged pipeline identity — [GitLab CI](/avanza/gitlab-ci.md).

See also [three perimeters](/avanza/three-perimeters.md).
