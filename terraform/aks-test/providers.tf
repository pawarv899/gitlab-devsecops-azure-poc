provider "azurerm" {
  features {}

  # Uses the ambient authenticated Azure CLI session for interactive,
  # human-driven work - same as ../bootstrap, ../main and ../acr.
}
