variable "name" {
  description = "Name of the Snap CD Runner: its Kubernetes namespace and service account, and the prefix of its Azure resources."
}
variable "resource_group_name" {}
variable "location" {}
variable "tenant_id" {}
variable "administrator_object_id" {
  description = "Entra group or user made administrator of the Key Vault."
}
variable "cluster_name" {}
variable "cluster_oidc_issuer_url" {}
variable "subscription_id" {}
