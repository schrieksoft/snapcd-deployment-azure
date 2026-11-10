variable "resource_group_name" {
  type        = string
  description = "The resource group into which to deploy the managed identity"
}

variable "location" {
  type        = string
  description = "The location into which to deploy the managed identity"
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "The OIDC issuer URL of the cluster whose service account is federated with the managed identity"
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "The name of the cluster, used in the default identity name"
}

variable "full_name" {
  type        = string
  default     = ""
  description = "The name of the managed identity and its federated credential. Derived from cluster, namespace and service account when empty"
}

variable "namespace" {
  type        = string
  description = "The namespace of the service account that is federated with the managed identity"
}

variable "service_account" {
  type        = string
  description = "The name of the service account that is federated with the managed identity"
}
