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
  description = "Existing Key Vault holding the sidecar's credentials. Empty runs the Agent without its sidecar."
  default     = ""
}
variable "claude_oauth_token_secret_name" {
  default = "claude-code-oauth-token"
}
variable "github_token_secret_name" {
  default = ""
}

variable "tenant_id" {}
variable "snapcd_agent_workload_identity_client_id" {}

// From snapcd_server_infra, snapcd_server_infra_config and snapcd_agent_infra.
variable "snapcd_server_akv_url" {}
variable "snapcd_agent_client_secret_reference" {}
