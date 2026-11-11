variable "name" {
  description = "Name of the Snap CD Agent: its Kubernetes namespace and service account, and the prefix of its Azure resources."
}
variable "resource_group_name" {}
variable "location" {}
variable "cluster_name" {}
variable "cluster_oidc_issuer_url" {}
variable "backend_akv_name" {
  description = "Existing Key Vault holding credentials put in by hand. Empty for none."
  default     = ""
}
variable "backend_akv_resource_group_name" {
  default = ""
}
variable "claude_credential" {
  description = "OAuthToken, ApiKey, or None to run the Agent without its sidecar."
  default     = "None"
}
variable "anthropic_api_key_secret_name" {
  default = "snapcd-agent-anthropic-api-key"
}
variable "claude_oauth_token_secret_name" {
  description = "Secret in the backend Key Vault holding the Claude subscription token."
  default     = "snapcd-agent-claude-code-oauth-token"
}
variable "github_token_enabled" {
  description = "Whether the backend Key Vault holds a GitHub token for the sidecar."
  default     = false
}
variable "github_token_secret_name" {
  default = "snapcd-agent-github-token"
}
