variable "bootstrap_snapcd_url" {
  default     = "http://localhost:7000"
  description = "The bootstrap Snap CD Server that deploys this configuration, as this machine reaches it."
}
variable "bootstrap_snapcd_client_id" {}
variable "bootstrap_snapcd_client_secret" {
  sensitive = true
}
variable "bootstrap_snapcd_organization_id" {}
variable "bootstrap_snapcd_server_url_from_runner" {
  default     = "http://snapcd-server:5000"
  description = "The bootstrap Snap CD Server as its Runner reaches it, for the State Store backend."
}

variable "bootstrap_runner_name" {}
variable "bootstrap_stack_name" {
  default     = "bootstrap"
  description = "Stack on the bootstrap Snap CD that holds this deployment."
}
variable "bootstrap_namespace_name" {
  default     = "azure"
  description = "Namespace on the bootstrap Snap CD that holds this deployment's Modules."
}

variable "name" {
  default     = "snapcd"
  description = "Name of the Azure resource group, virtual network and AKS cluster."
}

variable "tenant_id" {}
variable "subscription_id" {}
variable "location" {}
variable "administrator_object_id" {
  description = "Entra group or user that administers the AKS cluster."
}

variable "dns_zone_name" {
  default     = ""
  description = "Existing Azure DNS zone to publish the gateway in, e.g. example.com. Empty to use only <label>.<region>.cloudapp.azure.com."
}
variable "dns_zone_resource_group_name" {
  default     = ""
  description = "Resource group of dns_zone_name."
}
variable "dns_record_name" {
  default     = "snapcd"
  description = "Record created in dns_zone_name for the gateway."
}

variable "claude_oauth_token_secret_name" {
  default     = ""
  description = "Name of a Snap CD stack secret holding the Claude OAuth token for the Agent's sidecar. Create the secret by hand first. Empty to leave the sidecar without a credential."
}


variable "snapcd_server_name" {
  default     = "snapcd-server"
  description = "Name of the Snap CD Server: its Kubernetes namespace, release and service account, and the prefix of its Key Vault, SQL server and database."
}
variable "snapcd_runner_name" {
  default     = "snapcd-runner"
  description = "Name of the Snap CD Runner: its Kubernetes namespace, release and service account, and the prefix of its Key Vault."
}
variable "snapcd_agent_name" {
  default     = "snapcd-agent"
  description = "Name of the Snap CD Agent: its Kubernetes namespace, release and service account."
}

variable "snapcd_server_bus_type" {
  default     = "SqlServer"
  description = "Message bus of the Snap CD Server: SqlServer (in its database) or AzureServiceBus (a namespace created in snapcd_server_infra)."
  validation {
    condition     = contains(["SqlServer", "AzureServiceBus"], var.snapcd_server_bus_type)
    error_message = "snapcd_server_bus_type must be SqlServer or AzureServiceBus."
  }
}
