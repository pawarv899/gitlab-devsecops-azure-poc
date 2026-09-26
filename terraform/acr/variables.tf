variable "project" {
  description = "Short project identifier used in resource naming."
  type        = string
  default     = "petclinic-poc"
}

variable "location" {
  description = "Azure region for the ACR resource. Should match the region used by ../main (the CI VM)."
  type        = string
  default     = "centralindia"
}

variable "tags" {
  description = "Common tags applied to resources created by this layer."
  type        = map(string)
  default = {
    Project    = "GitLab-DevSecOps-Azure-POC"
    ManagedBy  = "Terraform"
    Layer      = "acr"
    Disposable = "true"
  }
}

# --- Cross-layer state read (../main, for the CI VM's identity) ---

variable "tfstate_resource_group_name" {
  description = "Resource group holding the shared Terraform state storage account (from ../bootstrap)."
  type        = string
  default     = "rg-petclinic-poc-tfstate"
}

variable "tfstate_storage_account_name" {
  description = "Storage account holding Terraform state (from ../bootstrap output: storage_account_name). No default - environment-specific generated value."
  type        = string
}

variable "tfstate_container_name" {
  description = "Blob container holding Terraform state files (from ../bootstrap)."
  type        = string
  default     = "tfstate"
}
