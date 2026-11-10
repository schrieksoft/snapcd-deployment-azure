variable "name" {
  description = "Name of the Snap CD Agent: its Kubernetes namespace and service account, and the prefix of its Azure resources."
}
variable "resource_group_name" {}
variable "location" {}
variable "cluster_name" {}
variable "cluster_oidc_issuer_url" {}
variable "key_vault_enabled" {
  default = false
}
variable "snapcd_server_akv_id" {}
variable "snapcd_agent_client_secret_name" {
  description = "Secret in the Server's Key Vault holding the Agent's client secret. Only with key_vault_enabled."
  default     = ""
}
