# Partial backend configuration (deliberate). Values are supplied at
# `terraform init` time via -backend-config=backend.hcl (see
# backend.hcl.example), not hardcoded here.

terraform {
  backend "azurerm" {}
}
