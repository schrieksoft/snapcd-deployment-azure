variable "resource_group_name" {}
variable "location" {
  description = "Azure region in its short form, as az account list-locations shows it in the name column, for example eastus2."
  validation {
    condition     = can(regex("^[a-z][a-z0-9]+$", var.location))
    error_message = "location must be the short form of the Azure region, for example eastus2 or westeurope, not a display name such as East US 2."
  }
}
variable "ingress_subnet_id" {}
variable "private_gateway_reserved_ip" {}
variable "public_dns_label" {
  description = "Azure DNS label of the gateway, or its prefix with public_dns_label_random_suffix."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,54}[a-z0-9]$", var.public_dns_label))
    error_message = "public_dns_label must start with a letter, end with a letter or a digit, and hold only lower-case letters, digits and hyphens: 2 to 56 characters."
  }
}
variable "public_dns_label_random_suffix" {
  default = true
}
variable "dns_zone_name" {
  description = "Existing Azure DNS zone to publish the gateway in. Empty to use only the cloudapp.azure.com name."
  default     = ""
}
variable "dns_zone_resource_group_name" {
  default = ""
}
variable "dns_record_name" {
  default = "snapcd"
}
