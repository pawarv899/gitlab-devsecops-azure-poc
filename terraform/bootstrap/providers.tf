provider "azurerm" {
  features {}

  # Uses the ambient authenticated Azure CLI session (az login, run
  # outside of Terraform). No client secret or service principal is
  # configured here - see docs/production-readiness.md for the tradeoffs
  # of this authentication model at production scale.
}
