variable "snapcd_server_akv_id" {}
variable "snapcd_server_akv_url" {}
variable "keepers" {
  description = "Change to generate new values for every key and secret here."
  default     = { iteration = 1 }
}
