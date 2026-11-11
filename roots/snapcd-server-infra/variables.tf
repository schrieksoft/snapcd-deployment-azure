variable "name" {
  description = "Name of the Snap CD Server: its Kubernetes namespace and service account, and the prefix of its Azure resources."
}
variable "resource_group_name" {}
variable "location" {}
variable "tenant_id" {}
variable "administrator_object_id" {
  description = "Entra group made administrator of the Key Vault and Entra administrator of the SQL server."
}
variable "cluster_name" {}
variable "cluster_oidc_issuer_url" {}
variable "apps_subnet_id" {
  description = "Subnet the Server's pods run in, allowed through the SQL server's firewall."
}
variable "sql_database_sku" {
  default = "S1"
}
variable "sql_database_max_size_gb" {
  default = 2
}
variable "allow_bootstrap_runner_ip" {
  description = "Open the SQL server's firewall to the public address this job runs from, so snapcd_server_infra_config can create the database user."
  default     = true
}
variable "bus_type" {
  description = "SqlServer keeps the Server's message bus in its database; AzureServiceBus creates a Service Bus namespace for it."
  default     = "SqlServer"
  validation {
    condition     = contains(["SqlServer", "AzureServiceBus"], var.bus_type)
    error_message = "bus_type must be SqlServer or AzureServiceBus."
  }
}
