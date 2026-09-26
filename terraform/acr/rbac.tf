# Reads the CI VM's system-assigned managed identity principal ID from
# ../main's remote state, instead of a human copy-pasting the ID by hand.
# Read-only: this data source cannot modify ../main's state, only read
# its outputs. Uses the same backend storage account/container as our
# own backend.tf, pointed at ../main's specific state key.
data "terraform_remote_state" "ci" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.tfstate_container_name
    key                  = "devsecops-poc.tfstate" # ../main's state key
    # No access_key here - falls back to the ARM_ACCESS_KEY environment
    # variable, the same one supplied at `terraform init` time (see
    # ../../README.md). Never hardcoded into a committed file.
  }
}

# The ONLY role assignment this layer creates: the CI VM's existing
# identity gets AcrPush, scoped to this ACR only. No Owner/Contributor,
# no other role, and explicitly no AKS permissions of any kind - that
# boundary is enforced by this simply being the only role_assignment
# resource in this entire layer.
resource "azurerm_role_assignment" "ci_acr_push" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPush"
  principal_id         = data.terraform_remote_state.ci.outputs.ci_vm_system_identity_principal_id
}
