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
variable "namespace" {
  default = "snapcd-server"
}
variable "public_hostname" {
  description = "Hostname the Server is served on through the Istio gateway."
}
variable "cluster_issuer" {
  description = "cert-manager ClusterIssuer for the Server's certificate."
  default     = "letsencrypt-prod"
}
variable "admin_email" {
  description = "Email of the pre-seeded system administrator."
  default     = "admin@preseeded.io"
}

// Key Vault mode: set by snapcd_server_infra and snapcd_server_infra_config. Empty keeps the keys generated here.
variable "tenant_id" {
  default = ""
}
variable "snapcd_server_akv_url" {
  default = ""
}
variable "snapcd_server_workload_identity_client_id" {
  default = ""
}
variable "snapcd_server_token_signing_public_key_pem" {
  default = ""
}
variable "snapcd_server_token_signing_key_reference" {
  default = ""
}
variable "snapcd_server_token_encryption_key_reference" {
  default = ""
}
variable "snapcd_server_state_store_key_reference" {
  default = ""
}
variable "snapcd_server_secret_store_key_reference" {
  default = ""
}
variable "snapcd_server_admin_password_reference" {
  default = ""
}
variable "snapcd_runner_client_secret_reference" {
  default = ""
}
variable "snapcd_agent_client_secret_reference" {
  default = ""
}
