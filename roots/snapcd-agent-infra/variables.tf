variable "name" {
  description = "Name of the Snap CD Agent: its Kubernetes namespace and service account, and the prefix of its Azure resources."
}
variable "resource_group_name" {}
variable "location" {}
variable "cluster_name" {}
variable "cluster_oidc_issuer_url" {}
variable "snapcd_server_akv_id" {}
variable "snapcd_agent_client_secret_name" {
  description = "Secret in the Server's Key Vault holding the Agent's client secret."
}
variable "backend_akv_name" {
  description = "Existing Key Vault holding credentials put in by hand. Empty for none."
  default     = ""
}
variable "backend_akv_resource_group_name" {
  default = ""
}
variable "claude_oauth_token_secret_name" {
  description = "Secret in the backend Key Vault holding the Claude subscription token."
  default     = "claude-code-oauth-token"
}
variable "github_token_secret_name" {
  description = "Secret in the backend Key Vault holding a GitHub token for the sidecar. Empty for none."
  default     = ""
}
