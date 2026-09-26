# Production Readiness

Written honestly, on purpose: this POC proves a real, working end-to-end pipeline and a real, running 3-service deployment on AKS — verified with live evidence (application logs, Eureka registry queries, config-server API responses, `kubectl top`), not just "the pods say Running." It is not a production system. This page separates what's genuinely implemented from what's simplified for the POC and from what a production rollout would still require.

## Implemented and verified with real evidence

- **Full CI pipeline**: build, unit tests, SonarQube Quality Gate, SAST, Dependency Scanning, Secret Detection, all 8 service images built and pushed to ACR, all 8 scanned by Trivy — a real pipeline run, not a mock.
- **Zero static credentials anywhere in the pipeline or cluster** — Managed Identity end-to-end for registry push and pull.
- **Layered, independently-stated Terraform** across 4 layers, applied with human review of each plan before every apply.
- **A real AKS cluster, sized against measured capacity** — node allocatable CPU/memory and existing `kube-system` overhead were inspected via `kubectl describe node`/`kubectl top` *before* choosing pod resource requests, not guessed.
- **Real application-level integration, not just pod health**: Eureka registration was confirmed by directly querying the registry API (`GET /eureka/apps/VETS-SERVICE`) and by reading both sides' logs (registering service / registered instance). Centralized configuration was confirmed by querying config-server's own REST API and seeing the actual resolved property set a running service received.
- **GitOps registration and rendering**: Argo CD's repo-server was observed, via its own logs, actually cloning the private repository over the registered SSH credential and running `helm template` against the real chart — not merely "the Application object exists."

## Real defects found during validation, not glossed over

- **`spring.config.import: optional:configserver:...` did not behave as optional.** Two of the three services crashed (uncaught `ConnectException`) on their first startup attempt because `config-server` wasn't reachable yet, and only became stable after Kubernetes' automatic restart backoff gave `config-server` time to come up. A production rollout needs either an init-container dependency wait, a Job-based readiness gate, or an accepted, documented startup-order risk — this POC currently relies on Kubernetes' restart backoff alone.
- **`config-server`'s own `/actuator/health` endpoint is shadowed by its own generic Spring Cloud Config route** (`/{application}/{profile}`) — a request to `/actuator/health` is interpreted as a request for an application named `actuator` with profile `health`, returning a slow, wrong payload instead of a fast actuator health check. This was the direct cause of the startup/liveness probe timeouts observed. Not yet fixed in this POC; a real fix would separate the actuator port (`management.server.port`) from the main port, or otherwise disambiguate the routes.
- **CPU headroom on the single TEST node is razor-thin** (measured: ~38m of 1900m allocatable free once `kube-system`, Argo CD, and the 3 app pods are all accounted for). This is why the Helm chart pins `maxSurge: 0, maxUnavailable: 1` on every Deployment — a default rolling update's momentary extra-pod surge would not have fit.

## Deliberate POC simplifications

| Area | POC choice | Why |
|---|---|---|
| Trivy severity gating | `allow_failure: true`, no exit-code threshold | Findings stay visible without blocking a demo pipeline; a real gate needs an agreed severity threshold and exception process |
| Argo CD sync | Manual only | Removes one class of "it deployed by itself" surprise while building/validating; production would typically automate sync with `selfHeal` for a stable environment |
| Application scope | 3 of 8 upstream services | Proves the full dependency chain (config → discovery → business service) within one small node's real capacity, without paying for the other 5 |
| AKS networking | kubenet, no ingress controller, no LoadBalancer exposed | Keeps the POC's network surface minimal; nothing here is reachable outside the cluster yet |
| ACR network exposure | Public endpoint (Basic SKU has no IP-restriction option) | RBAC + disabled admin account is the actual boundary at this SKU tier, not network restriction |
| CI runner | Single self-hosted VM, not autoscaled | One VM is enough to demonstrate the pipeline; not sized or scaled for concurrent team usage |
| Terraform backend auth | Storage account access key via `ARM_ACCESS_KEY` | Simpler for a single-operator POC than setting up AzureAD RBAC-based backend auth |

## Production-grade improvements still required

- **Ingress and TLS** — nothing is exposed outside the cluster today. Production needs an ingress controller (or Application Gateway) with real TLS termination and DNS.
- **Automated image-tag promotion** — today, promoting an image from CI to the Helm chart is a manual `values.yaml` edit and commit. Production would automate this (e.g. a promotion job, or a tool like Argo CD Image Updater) with an audit trail and approval gate.
- **Automated sync with health-based rollback** — manual sync doesn't scale operationally; production needs automated sync with `selfHeal`, plus rollback on failed health checks.
- **Fix the `config-server` health-endpoint collision** and the **non-optional `optional:configserver` startup dependency**, both described above.
- **Multi-replica deployments with a real Pod Disruption Budget** — every Deployment currently runs `replicas: 1`; there is no redundancy.
- **A larger or multi-node cluster** — the current single `Standard_D2s_v5` node has essentially no CPU headroom; production sizing needs real load data, not a POC's idle-state measurement.
- **Secrets management** — no Kubernetes `Secret` objects are used yet (none of the 3 deployed services need one); a production rollout with `genai-service` would need a real secrets story (Azure Key Vault CSI driver, External Secrets Operator, or similar) rather than manually-applied plain `Secret` manifests.
- **Network policy and pod security standards** — none are currently enforced in the cluster.
- **Observability** — no centralized logging, metrics, or tracing is deployed yet, despite the application already emitting Micrometer/Zipkin-compatible signals.
- **Infrastructure-as-code scanning** (`tfsec`/`checkov`) and **DAST** — not wired into the pipeline.
- **Multi-environment promotion (UAT/PROD)** with a separate, isolated PROD AKS cluster and a real approval gate — this POC only reaches a single TEST environment.
- **Backend authentication for Terraform state** — moving from storage-account access keys to AzureAD RBAC-based backend auth for better auditability.
