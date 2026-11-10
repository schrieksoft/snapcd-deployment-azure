variable "resource_group_name" {}
variable "location" {}
variable "ingress_subnet_id" {}
variable "private_gateway_reserved_ip" {}
variable "public_gateway_domain_name_label" {}
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
