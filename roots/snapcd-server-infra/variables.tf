variable "resource_group_name" {}
variable "location" {}
variable "tenant_id" {}
variable "administrator_object_id" {
  description = "Entra group or user made administrator of the Key Vault."
}
variable "cluster_name" {}
variable "cluster_oidc_issuer_url" {}
variable "namespace" {
  default = "snapcd-server"
}
