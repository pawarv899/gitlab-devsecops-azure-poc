variable "project" {
  description = "Short project identifier used in resource naming."
  type        = string
  default     = "petclinic-poc"
}

variable "location" {
  description = <<-EOT
    Azure region for the Terraform remote-state resources.
    Default is a placeholder - confirm quota/SKU availability for your
    own subscription/region before running apply.
  EOT
  type        = string
  default     = "centralindia"
}

variable "state_resource_group_name" {
  description = "Name of the dedicated resource group that holds Terraform remote-state resources."
  type        = string
  default     = "rg-petclinic-poc-tfstate"
}

variable "state_container_name" {
  description = "Name of the private blob container that stores Terraform state files."
  type        = string
  default     = "tfstate"
}

variable "tags" {
  description = "Common tags applied to bootstrap resources."
  type        = map(string)
  default = {
    Project    = "GitLab-DevSecOps-Azure-POC"
    ManagedBy  = "Terraform"
    Layer      = "bootstrap"
    Disposable = "true"
  }
}
