# Reads the shared ACR's resource ID from ../acr's remote state, instead
# of a human copy-pasting it by hand. Read-only: this data source cannot
# modify ../acr's state, only read its outputs.
data "terraform_remote_state" "acr" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.tfstate_container_name
    key                  = "acr.tfstate" # ../acr's state key
    # No access_key here - falls back to the ARM_ACCESS_KEY environment
    # variable, the same one supplied at `terraform init` time.
  }
}

# The ONLY role assignment this layer creates: the AKS cluster's
# auto-created kubelet identity gets AcrPull, scoped to the existing
# shared ACR only. No Owner/Contributor, no other role, and no role is
# granted to any CI identity or other principal on this cluster.
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = data.terraform_remote_state.acr.outputs.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks_test.kubelet_identity[0].object_id
}
