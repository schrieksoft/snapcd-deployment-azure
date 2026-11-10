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
variable "claude_oauth_token" {
  description = "Claude credential for the Agent's sidecar. Set this or claude_api_key."
  default     = ""
  sensitive   = true
}
variable "claude_api_key" {
  default   = ""
  sensitive = true
}

variable "tenant_id" {}
variable "snapcd_agent_workload_identity_client_id" {}

// From snapcd_server_infra, snapcd_server_infra_config and snapcd_agent_infra.
variable "snapcd_server_akv_url" {}
variable "snapcd_agent_client_secret_reference" {}
