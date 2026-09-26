# DevSecOps Controls

Security scanning is wired into the pipeline as ordinary jobs with the same visibility as build/test — not a separate, optional cleanup pass.

## Static Application Security Testing (SAST)

GitLab's maintained `Jobs/SAST.gitlab-ci.yml` template. Job names are not hardcoded in `.gitlab-ci.yml` — they depend on GitLab's own language auto-detection and the project's plan tier (e.g. `semgrep-sast` and/or `gitlab-advanced-sast` for a Java project).

## Dependency Scanning

GitLab's maintained `Jobs/Dependency-Scanning.v2.gitlab-ci.yml` template — the current SBOM-based replacement for the deprecated Gemnasium-based scanner. Auto-detects the multi-module Maven project's `pom.xml` files; resolves the dependency graph via a `.pre`-stage helper job, then scans it in the `test` stage.

## Secret Detection

GitLab's maintained `Jobs/Secret-Detection.gitlab-ci.yml` template. Scans only new/incremental commits by default (`GIT_DEPTH=50`) — a full historic-commit scan was deliberately treated as a separate, explicitly-approved action, not folded into routine pipeline runs, since it's a heavier one-off operation.

## Static code quality — SonarQube

Runs as its own job (`sonarqube`), not folded into `build`, specifically so a SonarQube outage can never block the build or image-publishing stages — only its own job. The Quality Gate result is blocking (`sonar.qualitygate.wait=true`); a failed gate fails the pipeline.

## Container image scanning — Trivy

Scans every pushed image by its **exact digest** (`image@sha256:...`), not merely its mutable tag — guaranteeing the scanned bytes are the exact bytes that were pushed, not a same-tag image that could theoretically differ. All severities are reported, with no `.trivyignore` suppression list and no `--ignore-unfixed` filtering.

**Deliberate POC simplification: `allow_failure: true`, no `--exit-code` severity gate.** Findings are generated, retained as a GitLab-native Container Scanning report, and fully visible — but do not block the pipeline. This was a conscious choice for demonstration purposes (see [`production-readiness.md`](production-readiness.md)): a production pipeline should gate on at least CRITICAL/HIGH findings with a documented, time-boxed exception process for anything allowed through.

## Secrets handling

No job in this pipeline handles a static, long-lived credential of any kind:
- **ACR authentication** uses the CI host's Azure Managed Identity, exchanged for a short-lived ACR token via IMDS + ACR's own OAuth endpoint — never a service-principal secret or an ACR admin password (the ACR admin account is disabled in Terraform).
- **AKS image pulls** use the cluster's kubelet Managed Identity with an `AcrPull` role assignment — no `imagePullSecret`.
- **SonarQube's token** is a masked + protected GitLab CI/CD variable — never present in `.gitlab-ci.yml` itself.
- **Argo CD's repository credential** (a read-only, project-scoped GitLab Deploy Key) is created and applied directly by a human — never generated, transmitted, or displayed by any automation or AI tooling involved in building this POC.

## What's intentionally *not* covered by automated scanning here

- **License compliance scanning** — not enabled in this POC.
- **DAST** (dynamic scanning against a running instance) — not enabled; the TEST environment has no public endpoint to scan yet in this POC's current state.
- **Infrastructure-as-code scanning** (e.g. `tfsec`/`checkov` against the Terraform layers) — not currently wired into the pipeline.

See [`production-readiness.md`](production-readiness.md) for these as explicit production-readiness gaps, not oversights.
