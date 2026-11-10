variable "vnet_name" {
  type        = string
  description = "Name of of the vnet to deploy"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group to deploy resources into"
}

variable "location" {
  type        = string
  description = "Location into which to deploy Azure resources"
}

variable "address_space_apps" {
  type        = string
  description = "Address space to use of the 'apps' subnet"
  default     = "100.0.0.0/22"
}

variable "address_space_system" {
  type        = string
  description = "Address space to use of the 'system' subnet"
  default     = "100.0.4.0/22"
}

variable "address_space_ingress" {
  type        = string
  description = "Address space to use of the 'ingress' subnet"
  default     = "100.0.8.0/23"
}
