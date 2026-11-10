variable "cluster_host" {
  sensitive = true
}
variable "cluster_ca_certificate" {
  sensitive = true
}
variable "cluster_token" {
  sensitive = true
}
variable "chart_version" {
  description = "Version of the charts at oci://ghcr.io/schrieksoft/charts."
}
variable "name" {
  description = "Name of the Snap CD Agent: its Kubernetes namespace, release and service account."
}
variable "server_url" {
  description = "Server URL as the Agent reaches it inside the cluster."
}
variable "backend_akv_name" {
  description = "Existing Key Vault holding the sidecar's credentials. Needed unless claude_credential is None."
  default     = ""
}
variable "claude_credential" {
  description = "OAuthToken, ApiKey, or None to run the Agent without its sidecar."
  default     = "None"
}
variable "anthropic_api_key_secret_name" {
  default = "snapcd-agent-anthropic-api-key"
}
variable "claude_oauth_token_secret_name" {
  default = "snapcd-agent-claude-code-oauth-token"
}
variable "github_token_enabled" {
  description = "Whether the backend Key Vault holds a GitHub token for the sidecar."
  default     = false
}
variable "github_token_secret_name" {
  default = "snapcd-agent-github-token"
}

variable "tenant_id" {}
variable "snapcd_agent_workload_identity_client_id" {}

// From snapcd_server_infra, snapcd_server_infra_config and snapcd_agent_infra.
variable "snapcd_server_akv_url" {}
variable "snapcd_agent_client_secret_reference" {}
