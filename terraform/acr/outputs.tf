output "acr_id" {
  description = "Resource ID of the ACR. Needed by the TEST/PROD AKS layers to grant their kubelet identities AcrPull."
  value       = azurerm_container_registry.this.id
}

output "acr_name" {
  description = "Name of the ACR."
  value       = azurerm_container_registry.this.name
}

output "acr_login_server" {
  description = "Login server hostname (e.g. <name>.azurecr.io). Used by .gitlab-ci.yml and the Helm chart's values.yaml to reference images."
  value       = azurerm_container_registry.this.login_server
}
