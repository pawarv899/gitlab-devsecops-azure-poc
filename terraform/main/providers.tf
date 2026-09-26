provider "azurerm" {
  features {}

  # Uses the ambient authenticated Azure CLI session for interactive,
  # human-driven work. GitLab CI (the Azure CI VM) authenticates
  # separately, via its system-assigned managed identity - not configured
  # here.
}
