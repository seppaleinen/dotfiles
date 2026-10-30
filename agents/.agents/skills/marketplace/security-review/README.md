# Security Review

## What does it do?

Walks an agent through a high-confidence security review following Avanza Technical Security Requirements (`security-guidelines`). Use general bug-class knowledge when needed to investigate a finding.

## Problems it solves

- Inconsistent security-review reports
- Flagging theoretical or framework-mitigated issues as vulnerabilities
- Missing Avanza-specific rules during a review

## Example prompts

- "Find vulnerabilities in this project."
- "Audit the security for this application."
- "Security review this diff for IDOR and injection."

## Requirements

Install `security-guidelines` knowledge (`aza-market install security-guidelines`). `knowledge-lookup` is used to load it.
