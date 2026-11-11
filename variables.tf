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

variable "public_dns_label" {
  default     = null
  description = "Azure DNS label of the gateway, which makes the Server <label>.<region>.cloudapp.azure.com. With public_dns_label_random_suffix, the prefix of the label. Defaults to name."
  validation {
    condition     = var.public_dns_label == null || can(regex("^[a-z][a-z0-9-]{0,54}[a-z0-9]$", var.public_dns_label))
    error_message = "public_dns_label must start with a letter, end with a letter or a digit, and hold only lower-case letters, digits and hyphens: 2 to 56 characters."
  }
}
variable "public_dns_label_random_suffix" {
  default     = true
  description = "Add a hyphen and five random characters to public_dns_label. Labels are unique per Azure region, so this keeps two deployments from colliding."
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

variable "backend_akv_name" {
  default     = ""
  description = "Existing Key Vault, created and filled by hand, holding the Agent sidecar's credentials. Needed unless claude_credential is None."
}
variable "backend_akv_resource_group_name" {
  default     = ""
  description = "Resource group of backend_akv_name."
}
variable "claude_credential" {
  description = "Claude credential the Agent's sidecar reads from the backend vault: OAuthToken, ApiKey, or None to run the Agent without its sidecar."
  default     = "None"
  validation {
    condition     = contains(["None", "OAuthToken", "ApiKey"], var.claude_credential)
    error_message = "claude_credential must be None, OAuthToken or ApiKey."
  }
}
variable "claude_oauth_token_secret_name" {
  default     = "snapcd-agent-claude-code-oauth-token"
  description = "Secret in the backend Key Vault holding the Claude subscription token (claude setup-token). Read only with claude_credential OAuthToken."
}
variable "anthropic_api_key_secret_name" {
  default     = "snapcd-agent-anthropic-api-key"
  description = "Secret in the backend Key Vault holding the Anthropic API key. Read only with claude_credential ApiKey."
}
variable "github_token_enabled" {
  default     = false
  description = "Whether the Agent's sidecar also reads a GitHub token from the backend Key Vault. Only with a claude_credential."
}
variable "github_token_secret_name" {
  default     = "snapcd-agent-github-token"
  description = "Secret in the backend Key Vault holding the GitHub token. Read only with github_token_enabled."
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
  default     = "AzureServiceBus"
  description = "Message bus of the Snap CD Server: AzureServiceBus (a namespace created in snapcd_server_infra) or SqlServer (in its database)."
  validation {
    condition     = contains(["SqlServer", "AzureServiceBus"], var.snapcd_server_bus_type)
    error_message = "snapcd_server_bus_type must be SqlServer or AzureServiceBus."
  }
}
