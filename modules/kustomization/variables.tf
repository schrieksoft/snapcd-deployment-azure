variable "absolute_paths" {
  type        = list(string)
  description = "A list of absolute paths to resources (individual YAML files, or folders containing a kustomization.yaml) with base resources that the overlay should be applied to"
}

variable "common_annotations" {
  type        = map(string)
  description = "Annotations to add to all resources"
  default     = null
}

variable "common_labels" {
  type        = map(string)
  description = "Labels to add to all resources"
  default     = null
}

variable "components" {
  type        = list(string)
  description = "List of component resources"
  default     = null
}

variable "crds" {
  type        = list(string)
  description = "List of CRD files"
  default     = null
}

variable "generators" {
  type        = list(string)
  description = "List of generator resources"
  default     = null
}

variable "name_prefix" {
  type        = string
  description = "Prefix to add to all resource names"
  default     = null
}

variable "namespace" {
  type        = string
  description = "Namespace to add to all resources"
  default     = null
}

variable "name_suffix" {
  type        = string
  description = "Suffix to add to all resource names"
  default     = null
}

variable "transformers" {
  type        = list(string)
  description = "List of transformer resources"
  default     = null
}

variable "config_map_generators" {
  type = list(object({
    name      = optional(string)
    namespace = optional(string)
    behavior  = optional(string)
    envs      = optional(list(string))
    files     = optional(list(string))
    literals  = optional(list(string))
    options = optional(object({
      labels                   = optional(map(string))
      annotations              = optional(map(string))
      disable_name_suffix_hash = optional(bool)
    }))
  }))
  description = "ConfigMap generators"
  default     = []
}

variable "generator_options" {
  type = object({
    labels                   = optional(map(string))
    annotations              = optional(map(string))
    disable_name_suffix_hash = optional(bool)
  })
  description = "Generator options to apply to all generators"
  default     = null
}

variable "images" {
  type = list(object({
    name     = string
    new_name = optional(string)
    new_tag  = optional(string)
    digest   = optional(string)
  }))
  description = "Images to replace"
  default     = []
}

variable "replicas" {
  type = list(object({
    name  = string
    count = number
  }))
  description = "Replica count overrides"
  default     = []
}

variable "vars" {
  type = list(object({
    name = string
    obj_ref = optional(object({
      group       = optional(string)
      version     = optional(string)
      kind        = string
      name        = string
      namespace   = optional(string)
      api_version = optional(string)
    }))
    field_ref = optional(object({
      field_path = string
    }))
  }))
  description = "Variables for substitution"
  default     = []
}

variable "patches" {
  type = list(object({
    patch = optional(string)
    path  = optional(string)
    target = optional(object({
      group               = optional(string)
      version             = optional(string)
      kind                = optional(string)
      name                = optional(string)
      namespace           = optional(string)
      label_selector      = optional(string)
      annotation_selector = optional(string)
    }))
  }))
  default = []
}

variable "secret_generators" {
  type = list(object({
    name      = optional(string)
    namespace = optional(string)
    behavior  = optional(string)
    type      = optional(string)
    envs      = optional(list(string))
    files     = optional(list(string))
    literals  = optional(list(string))
    options = optional(object({
      labels                   = optional(map(string))
      annotations              = optional(map(string))
      disable_name_suffix_hash = optional(bool)
    }))
  }))
  default = []
}

variable "wait_for_workloads" {
  default = false
}

variable "wait_for_workloads_timeout_create" {
  default = "2m"
}

variable "wait_for_workloads_timeout_update" {
  default = "2m"
}
