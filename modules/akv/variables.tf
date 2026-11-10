variable "name" {
  type    = string
  default = null
}
variable "name_type" {
  type        = string
  default     = "full name"
  description = "Determines whether to use the \"name\" variable directly as the key vault name, or to use as a prefix to which a random string is added"
  validation {
    condition     = contains(["full name", "prefix"], var.name_type)
    error_message = "Valid values for the `name_type` variable are \"full name\" or \"prefix\""
  }
}

variable "network_acls" {
  default = []

  type = list(object({
    bypass                     = string
    default_action             = string
    virtual_network_subnet_ids = list(string)
  }))
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "soft_delete_retention_days" {
  type = string
}

variable "purge_protection_enabled" {
  type = string
}

variable "sku_name" {
  type = string
}

variable "enabled_for_deployment" {
  type = string
}

variable "enabled_for_disk_encryption" {
  type = string
}

variable "enabled_for_template_deployment" {
  type = string
}

variable "enable_rbac_authorization" {
  type = string
}

variable "administrator_object_ids" {
  type = list(string)
}

variable "tags" {
  default = {}

}
