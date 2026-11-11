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
  description = "Name of the Snap CD Runner: its Kubernetes namespace, release and service account."
}
variable "server_url" {
  description = "Server URL as the Runner reaches it inside the cluster."
}

variable "tenant_id" {}
variable "snapcd_runner_workload_identity_client_id" {}

// From snapcd_server_infra, snapcd_server_infra_config, snapcd_runner_infra and snapcd_runner_infra_config.
variable "snapcd_runner_akv_name" {}
variable "snapcd_runner_ssh_key_secret_name" {}
