variable "name" {
  description = "Name of the Snap CD Runner, used for its SSH key secret."
}
variable "key_vault_enabled" {
  default = false
}
variable "snapcd_runner_akv_url" {}
variable "keepers" {
  description = "Change to generate a new SSH key."
  default     = { iteration = 1 }
}
