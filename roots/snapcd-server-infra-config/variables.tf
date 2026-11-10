variable "name" {
  description = "Name of the Snap CD Server, used for its database user."
}
variable "key_vault_enabled" {
  default = false
}
variable "snapcd_server_akv_id" {}
variable "snapcd_server_akv_url" {}
variable "snapcd_server_mssql_server_fqdn" {}
variable "snapcd_server_mssql_database_name" {}
variable "snapcd_server_workload_identity_client_id" {}
variable "keepers" {
  description = "Change to generate new values for every key and secret here."
  default     = { iteration = 1 }
}
