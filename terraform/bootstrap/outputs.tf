output "resource_group_name" {
  description = "Name of the Terraform remote-state resource group."
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Name of the storage account holding Terraform state. Needed to configure the backend in ../main."
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Name of the private blob container holding Terraform state files."
  value       = azurerm_storage_container.tfstate.name
}

output "location" {
  description = "Azure region the state resources were created in."
  value       = azurerm_resource_group.tfstate.location
}

# Deliberately no access-key output here. Retrieve the key locally, only
# when needed, with:
#   az storage account keys list \
#     --resource-group <resource_group_name> \
#     --account-name <storage_account_name> \
#     --query "[0].value" -o tsv
# and pass it to `terraform init` via ARM_ACCESS_KEY or -backend-config,
# never by pasting it into a file that gets committed.
