output "url" {
  value = "https://${var.public_hostname}"
}

output "snapcd_server_url_in_cluster" {
  value = local.server_url
}

// The admin's password is in the Server's vault, as snapcd-server-admin-password.
output "admin_email" {
  value = var.admin_email
}
