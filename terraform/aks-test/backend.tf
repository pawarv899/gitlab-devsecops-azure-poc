# Partial backend configuration (deliberate) - same convention as
# ../main and ../acr. Uses the SAME bootstrap storage account/container,
# but its OWN state key ("aks-test.tfstate") so an apply here can never
# touch ../main's or ../acr's state.

terraform {
  backend "azurerm" {}
}
