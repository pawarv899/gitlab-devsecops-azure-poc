# Security Checklist — Before Publishing This Repository Publicly

Run through this before making the GitHub repository public, and again before any future push once the repository is live. Nothing here has been silently deleted — anything found is reported, not removed, without your review.

## Checked in this pass (see the assistant's report for exact results)

- [ ] No private keys (`BEGIN ... PRIVATE KEY`, `id_rsa`, `id_ed25519`, `.pem`, `.pfx`, `.ppk`)
- [ ] No API tokens/PATs (GitHub `ghp_`/`github_pat_`, GitLab `glpat-`, generic `token`/`api_key` assignments with real-looking values)
- [ ] No passwords or connection strings (`password=`, `Server=...;Password=...`, database URLs with embedded credentials)
- [ ] No Azure subscription IDs or tenant IDs in committed files
- [ ] No `.tfstate` or `.tfstate.backup` files
- [ ] No real `.tfvars` or `backend.hcl` files (only `.example` variants)
- [ ] No Kubernetes `Secret` manifests with real `data`/`stringData` values
- [ ] No Argo CD admin passwords or session tokens
- [ ] No GitLab Deploy Tokens/Keys, runner registration tokens, or CI/CD variable values
- [ ] No personal filesystem paths (e.g. `C:\Users\<name>\...`, `/home/<name>/...`) in comments or examples
- [ ] No real IP addresses tied to a still-live personal resource (CI host public IP, personal source-IP allowlist entries)
- [ ] No company/customer-confidential information (this is a personal/portfolio POC — should not apply, but re-check before publishing)

## Ongoing hygiene once the repository is public

- [ ] Add GitHub secret scanning (enabled by default on public repos) and push-protection.
- [ ] Never commit a real `terraform.tfvars` or `backend.hcl` — the `.gitignore` in this repo blocks them by pattern, but a forced `git add -f` can still bypass it.
- [ ] Rotate any credential that *was* ever real and committed to this project's *actual working* repositories (not this portfolio copy) as a matter of routine hygiene, independent of whether this scan found anything — history can be rewritten but caches/forks may retain old commits.
- [ ] If you fork this to actually deploy your own environment, keep your real `terraform.tfvars`, `backend.hcl`, and any `kubeconfig` out of git entirely (already covered by `.gitignore`, but review before your first commit).
- [ ] Review every placeholder value (`<your-acr-name>`, `<your-namespace>/<your-repo>`, `203.0.113.4/32`, etc.) before treating any file as ready to apply — they are intentionally non-functional until you substitute your own values.

## What "sanitized" means here, precisely

This repository was built by copying and genericizing artifacts from a real, working (but disposable) Azure/GitLab environment. Nothing in it ever contained a plaintext password, private key, or long-lived access token — the underlying project's own operating rules never allowed one to be written to a file in the first place (Managed Identity throughout, masked/protected CI/CD variables, human-applied Deploy Keys). What *was* redacted for this public copy is **identifying infrastructure detail** (a real ACR hostname, a real source IP, a real GitLab project path) that isn't secret by itself but has no reason to be published either.
