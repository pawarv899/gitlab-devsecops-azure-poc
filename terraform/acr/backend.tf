# Partial backend configuration (deliberate) - same convention as
# ../main. Uses the SAME bootstrap storage account/container, but its
# OWN state key ("acr.tfstate") so an apply here can never touch
# ../main's (the CI VM's) state.

terraform {
  backend "azurerm" {}
}
