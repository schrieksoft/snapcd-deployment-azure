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
  description = "Name of the Snap CD Server: its Kubernetes namespace, release and service account."
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

variable "tenant_id" {}
variable "snapcd_server_workload_identity_client_id" {}
variable "snapcd_server_mssql_server_fqdn" {}
variable "snapcd_server_mssql_database_name" {}

// From snapcd_server_infra and snapcd_server_infra_config.
variable "snapcd_server_akv_url" {}
variable "snapcd_server_token_signing_public_key_pem" {}
variable "snapcd_server_token_signing_key_reference" {}
variable "snapcd_server_token_encryption_key_reference" {}
variable "snapcd_server_state_store_key_reference" {}
variable "snapcd_server_secret_store_key_reference" {}
variable "snapcd_server_admin_password_reference" {}
variable "snapcd_runner_client_secret_reference" {}
variable "snapcd_agent_client_secret_reference" {}
variable "bus_type" {
  description = "SqlServer or AzureServiceBus, matching snapcd_server_infra."
  default     = "SqlServer"
}
variable "snapcd_server_servicebus_namespace_endpoint" {
  description = "sb:// address of the Server's Service Bus namespace. Only with bus_type AzureServiceBus."
  default     = ""
}
