# Entry point for TEST AKS. Resources are split into files by concern,
# matching the convention used in ../main and ../acr:
#   resource-group.tf - dedicated resource group for TEST AKS
#   network.tf          - VNet/subnet for kubenet node networking
#   aks.tf                - the AKS cluster and its system node pool
#   rbac.tf                - AcrPull grant to the AKS kubelet identity, read
#                             from ../acr's remote state
#
# Out of scope for this layer (see docs/production-readiness.md):
# ingress controller, Application Gateway, NAT Gateway, Bastion,
# database, private endpoints. The Kubernetes LoadBalancer Service that
# would expose the application is a kubectl/Argo CD manifest applied
# separately, not a Terraform resource here.
#
# PROD AKS is a separate, later layer - never this one.
